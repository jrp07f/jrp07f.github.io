import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/modals/modal_alert_dialog.dart';
import 'package:care_dart_sdk/ui/shared/ginger_alert_dialog.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:care_dart_sdk/utilities/date_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/models/scheduler_slots.dart';
import 'package:mini_ginger_web/navigation/app_routes.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';

class SchedulerModel extends NavigationModel {
  Map<SchedulerDate, List<SchedulerTime>> _availableTimes = {};
  OnboardSchedulerAvailabilityResponse response;

  Map<SchedulerDate, List<SchedulerTime>> get availableTimes => _availableTimes;

  String get companyName => api.companyName;
  String get companyImageUrl => api.companyImageUrl;
  SchedulerDate selectedDate;
  SchedulerTime selectedTime;

  bool peakLoad = false;

  String get timeZoneName => DateUtils.generateTimezoneName(DateTime.now());

  double timeScrollPosition = 0.0;
  double dateScrollPosition = 0.0;
  String audioName;
  String audioDuration;
  String error;

  final Logger log = Logger('GingerApp');

  @visibleForTesting
  LocalServiceAPI api;

  Origin origin;

  bool get hasAvailability =>
      response != null &&
      response.availableTimes != null &&
      response.availableTimes.isNotEmpty;

  bool get shouldPresentErrorState => error != null;

  LinkedHashMap<SchedulerDate, List<SchedulerTime>> searchableSlots =
      LinkedHashMap();
  List<SchedulerTime> visibleTimeSlots = [];

  SchedulerModel({this.api}) {
    api ??= serviceLocator.get<ServiceAPI>() as LocalServiceAPI;
  }

  List<SchedulerDate> get visibleDateSlots {
    return searchableSlots?.keys?.toList() ?? [];
  }

  /// This organises returned appointment times for easy and efficient look-up
  /// using a LinkedHashMap. With this looking up time slots in a day
  /// becomes 0(1) operation.
  @visibleForTesting
  void buildLookupCache() {
    searchableSlots.clear();

    List<SchedulerDate> times = response?.availableTimes
            ?.map((dateTime) => SchedulerDate(dateTime))
            ?.toList() ?? [];
    metricsProvider.track(AvailableAppointmentsLoaded(slots: times.length));

    for (final SchedulerDate slot in times) {
      var existing = searchableSlots[slot];
      if (existing != null) {
        existing.add(SchedulerTime(slot.localDateTime));
      } else {
        searchableSlots[slot] = [SchedulerTime(slot.localDateTime)];
      }
    }

    actionSelectDate(searchableSlots.keys.first);
  }

  void actionSelectDate(SchedulerDate date) {
    if (date == null) return;

    selectedDate = date;
    visibleTimeSlots = searchableSlots[date];

    calculateTimeScrollPosition(visibleTimeSlots ?? []);

    metricsProvider.track(WebSchedulerDateTappedEvent());

    notifyListeners();
  }

  @visibleForTesting
  void calculateDateScrollPosition(List<SchedulerDate> defaultDates) {
    double cellWidth = 88.0;

    dateScrollPosition = 0.0;
    defaultDates.asMap().forEach((index, date) {
      if (date == selectedDate) {
        dateScrollPosition = index * cellWidth;
      }
    });
  }

  void calculateTimeScrollPosition(List<SchedulerTime> defaultTimes) {
    double cellHeight = 56.dp;

    timeScrollPosition = 0.0;
    for (int index = 0; index < defaultTimes.length; index++) {
      if (defaultTimes[index].is8amLocally()) {
        //break out once we hit first 8am time boundary
        if (index == 0) {
          timeScrollPosition = 0.0;
        } else if (index >= defaultTimes.length - 3) {
          timeScrollPosition = 0.0;
        } else {
          timeScrollPosition = index * cellHeight;
        }
        break;
      }
    }
  }

  String getSlotTitle(SchedulerTime time) {
    return '${time.timeOfDay}, $timeZoneName';
  }

  void actionSelectTime(SchedulerTime time) {
    if (selectedTime == time) {
      /// Unselect selected time and exit early
      selectedTime = null;
      notifyListeners();
      return;
    }

    selectedTime = time;
    notifyListeners();

    metricsProvider.track(WebSchedulerTimeSelectedEvent(
      dateTime: time.localDateTime));
  }

  Future<void> load() async {
    busy = true;
    error = null;
    notifyListeners();

    try {
      await api.fetchMemberInfo();
      response = await api.onboardSchedulerAvailableTimes();
      peakLoad = response.peakLoad;
      if (peakLoad ?? false) {
        metricsProvider.track(WebSchedulerPeakLoadEvent());
      }

      buildLookupCache();
      maybeSkipScheduling();
    } on GingerDetailedError catch (e, stacktrace) {
      log.severe("Failed to fetch available times", e, stacktrace);
      error = e.message;
      metricsProvider.track(FailedToLoadAvailableTimesEvent(reason: e.message));
    } on GingerStatusError catch(e, stack) {
      error = R.current.unable_to_load_content;
      log.severe("Unable to load available times $e", e, stack);

      if (e.statusCode == 401) {
        metricsProvider.track(AuthorizationFailureEvent(
            reason: e.toString(), statusCode: e.statusCode));
      } else {
        metricsProvider.track(FailedToLoadAvailableTimesEvent(
            reason: e.toString(), statusCode: e.statusCode));
      }
    } catch (e, stackTrace) {
      error = R.current.unable_to_load_content;
      log.severe("Unable to load available times $e", e, stackTrace);
      metricsProvider.track(FailedToLoadAvailableTimesEvent(reason: e.toString()));
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> maybeSkipScheduling() async {
    var currentlyScheduled = response?.currentlyScheduled;
    if (currentlyScheduled != null) {
      selectedDate = SchedulerDate(currentlyScheduled);
      selectedTime = SchedulerTime(currentlyScheduled.toLocal());

      metricsProvider.track(SchedulerSkippedEvent());

      /// Proceed to the Confirmed Session screen
      _continue();
    }
  }

  Future<void> actionSubmitSelectedTime() async {
    busy = true;
    notifyListeners();

    try {
      if (selectedTime == null) return;
      metricsProvider.track(WebSchedulerBookTappedEvent(
        dateTime: selectedTime.localDateTime
      ));

      // Ensure local time is converted to UTC before sending to backend
      await api.onboardSchedulerSelectTime(selectedTime.localDateTime.toUtc());
      _continue();
    } on GingerDetailedError catch (e, stacktrace) {
      log.severe("Time selection failed with: $e", e, stacktrace);
      _showErrorDialog(e.message);
      metricsProvider.track(SchedulingFailedEvent(reason: e.message));
    } on GingerStatusError catch (e, stacktrace) {
      log.severe("Time selection failed with: $e", e, stacktrace);
      _showErrorDialog(
        R.current.unknown_error_message,
        onDismiss: onDismissErrorDialog,
      );
      metricsProvider.track(SchedulingFailedEvent(reason: e.message));
    } on SocketException catch(_) {
      var errorMessage = R.current.no_network_try_again;
      _showErrorDialog(errorMessage);
      metricsProvider.track(SchedulingFailedEvent(reason: errorMessage));
    } catch (e, stacktrace) {
      log.severe("Time selection failed to upload", e, stacktrace);
      var errorMessage = R.current.unknown_error_message;
      _showErrorDialog(errorMessage);
      metricsProvider.track(SchedulingFailedEvent(reason: errorMessage));
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void onDismissErrorDialog() {
    /// Clear outdated state and re-load available times
    _availableTimes = {};
    selectedDate = null;
    selectedTime = null;
    unawaited(load());
  }

  void _continue() {
    ScheduledSessionScreenArg arg = ScheduledSessionScreenArg(
        selectedTime.localDateTime);
    router.pushNamed(AppRoutes.sessionScheduled, arguments: arg);
  }

  void _showErrorDialog(String message, {Function onDismiss}) {
    api.modalService.showImmediately(HSCustomAlertModal(
      body: message,
      actions: [
        AlertActionConfig(
          text: R.current.ok,
          onPressed: () {
            onDismiss?.call();
          },
          isDefaultAction: true,
        )
      ],
    ));
  }

  void actionDateScrolled() {
    metricsProvider.track(WebSchedulerDateScrolledEvent());
  }

  void actionTimeScrolled() {
    metricsProvider.track(WebSchedulerTimeScrolledEvent());
  }
}
