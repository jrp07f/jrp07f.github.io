import 'dart:async';
import 'dart:io';

import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/models/activity.dart';
import 'package:care_dart_sdk/services/modal_service.dart';
import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/services/streams/service_events.dart';
import 'package:care_dart_sdk/ui/modals/busy_screen_modal_widget.dart';
import 'package:care_dart_sdk/ui/modals/modal_alert_dialog.dart';
import 'package:care_dart_sdk/ui/shared/ginger_alert_dialog.dart';
import 'package:care_dart_sdk/utilities/deeplink.dart';
import 'package:mini_ginger_web/navigation/app_routes.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:logging/logging.dart';

class MainAppModel extends NavigationModel {
  final Logger _log = Logger("GingerTabbedNavigator");
  bool shouldRebuildAllChildWidgets = false;
  StreamSubscription<DeepLinkEvent> _deepLinkSubscription;
  StreamSubscription<ServiceEvent> _serviceEventsSubscription;

  LocalServiceAPI get api => serviceLocator.get<ServiceAPI>();

  ModalService get modalService => serviceLocator.get<ModalService>();

  void clearChildWidgetsRebuildFlag() {
    shouldRebuildAllChildWidgets = false;
  }

  FutureOr<void> continueLaunch() async {
    var workflowHash = await serviceLocator.getAsync<String>(
      instanceName: 'workflowHash',
    );
    if (workflowHash.isNotEmpty) {
      listenToServiceEvents();

      try {
        var user = await api.authenticate(workflowHash);
        await api.metricsIdentify(user: user);

        /// Earliest point for initializing and ensuring that the content
        /// metadata is loaded into memory.
        await api.contentService.initActivitiesMetadataRoot();
        unawaited(api.loadIntakeInsuranceCompanies(fetchRemote: true));
        var workflow =
            await api.fetchFusionWorkflow(workflowHash);
        if (workflow.name == FusionWorkflow.guardianConsent) {
          launchGuardianConsent();
        } else {
          launchTeenClinicalEscalation();
        }
      } catch (e, s) {
        log.severe('Error while fetching fusion workflows: $e', e, s);
        router.pushNamedAndRemoveAll(
          AppRoutes.error,
          arguments: ErrorScreenArg(),
        );
      }

      return;
    }

    launchScheduler();
  }

  void listenToServiceEvents() {
    var deepLinkService = serviceLocator.get<DeepLinkService>();
    _deepLinkSubscription = deepLinkService.postOnboardEvents
        .listen(handleDeepLink)
      ..onError((e, stackTrace) {
        _log.warning("Error in post-onboard deeplink stream $e $stackTrace");
      });
    _serviceEventsSubscription = api.serviceEvents.listen(onServiceEvent);
  }

  void launchTeenClinicalEscalation() {
    router.pushNamedAndRemoveAll(AppRoutes.teenClinicalEscalation);
  }

  void launchGuardianConsent() {
    router.pushNamedAndRemoveAll(AppRoutes.guardianConsent);
  }

  void launchScheduler() {
    router.pushNamedAndRemoveAll(AppRoutes.scheduler);
  }

  Future<void> handleDeepLink(DeepLinkEvent event) async {
    DeepLink link = event.deepLink;

    switch (link?.intent?.runtimeType) {
      case ContentIntent:
        unawaited(presentActivity(link));
        break;
      case UnknownIntent:
      default:
        handleUnknownDeeplinkIntent(link);
    }
  }

  void handleUnknownDeeplinkIntent(DeepLink link) {
    _log.severe('Unable to handle deeplink intent ${link.intent}');
  }

  void onServiceEvent(ServiceEvent event) {
    _log.info(event.name);
  }

  Future<void> presentActivity(DeepLink link) async {
    var intent = link.intent as ContentIntent;

    if (intent.assignmentId != null) {
      unawaited(presentWithAssignmentId(link));
    } else if (intent.activityId != null) {
      unawaited(presentWithActivityId(link));
    } else {
      showUnableToLoadLibraryCardDialog();
    }
  }

  void showUnableToLoadLibraryCardDialog() async {
    modalService.showImmediately(HSCustomAlertModal(
      body: R.current.unable_to_load_assign_activity_error_text,
      actions: [AlertActionConfig(text: R.current.ok, onPressed: () {})],
    ));
  }

  Future<void> presentWithActivityId(DeepLink link) async {
    ContentIntent intent = link.intent;
    var busyModal = BusyScreenModalWidget();

    /// The delay ensures that an ongoing Navigator.push() calls complete.
    /// Hence, preventing re-entrant push issue.
    await Future.delayed(Duration.zero);
    modalService.show(busyModal);

    Activity activity =
        await api.getAvailableActivityByActivityId(intent.activityId);

    if (activity != null) {
      /// Though the above returns a [Future] which we can await, it does have
      /// an un-awaited runZoned call inside. Hence, the need for the short delay below.
      /// The delay ensures the content server starts before we present an activity
      await Future.delayed(const Duration(milliseconds: 50));

      modalService.dismiss(busyModal);
      unawaited(api.presentContent(activity, origin: intent.origin));
      return;
    } else {
      try {
        // Pull assigned activities from the server
        await api.assignActivity(intent.activityId);
        Activity activity =
            await api.getAvailableActivityByActivityId(intent.activityId);

        modalService.dismiss(busyModal);
        if (activity != null) {
          unawaited(api.presentContent(activity, origin: intent.origin));
          return;
        }
      } on SocketException catch (e, stacktrace) {
        modalService.dismiss(busyModal);
        _log.severe(
            'Socket exception occurred will fetching content', e, stacktrace);
      } catch (e, stacktrace) {
        modalService.dismiss(busyModal);
        _log.severe(
            'Unknown exception occurred will fetching content', e, stacktrace);
      }
    }

    /// If deeplink is opened from the self-care tab, showError dialog and
    /// do not switch tabs
    if (link.origin == DeeplinkOrigin.selfCare) {
      showUnableToLoadLibraryCardDialog();
      return;
    }

    // Show activity not available dialog if activity is null
    showUnableToLoadLibraryCardDialog();
  }

  Future<void> presentWithAssignmentId(DeepLink link) async {
    ContentIntent intent = link.intent;
    var busyModal = BusyScreenModalWidget();

    /// The delay ensures that an ongoing Navigator.push() calls complete.
    /// Hence, preventing re-entrant push issue.
    await Future.delayed(Duration.zero);
    modalService.show(busyModal);

    Activity activity = await api.getAvailableActivity(intent.assignmentId);

    if (activity != null) {
      /// Though the above returns a [Future] which we can await, it does have
      /// an un-awaited runZoned call inside. Hence, the need for the short delay below.
      /// The delay ensures the content server starts before we present an activity
      await Future.delayed(const Duration(milliseconds: 50));

      modalService.dismiss(busyModal);
      unawaited(api.presentContent(activity, origin: intent.origin));
      return;
    } else {
      try {
        // Pull assigned activities from the server
        await api.assignedActivities(fetchRemote: true);
        Activity activity = await api.getAvailableActivity(intent.assignmentId);

        if (activity != null) {
          modalService.dismiss(busyModal);
          unawaited(api.presentContent(activity, origin: intent.origin));
          return;
        }
      } on SocketException catch (e, stacktrace) {
        _log.severe(
            'Socket exception occurred will fetching content', e, stacktrace);
      } catch (e, stacktrace) {
        _log.severe(
            'Unknown exception occurred will fetching content', e, stacktrace);
      }
      modalService.dismiss(busyModal);
    }

    /// If deeplink is opened from the self-care tab, showError dialog and
    /// do not switch tabs
    if (link.origin == DeeplinkOrigin.selfCare) {
      showUnableToLoadLibraryCardDialog();
      return;
    }

    // Show activity not available dialog if activity is null
    showUnableToLoadLibraryCardDialog();
  }

  @override
  Future<void> dispose() async {
    await _deepLinkSubscription?.cancel();
    await _serviceEventsSubscription?.cancel();
    super.dispose();
  }
}
