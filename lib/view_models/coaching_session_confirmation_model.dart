import 'dart:io';
import 'dart:async';

import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/modals/modal_alert_dialog.dart';
import 'package:care_dart_sdk/ui/shared/ginger_alert_dialog.dart';
import 'package:care_dart_sdk/utilities/date_utils.dart';
import 'package:care_dart_sdk/utilities/environment_config.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:care_dart_sdk/utilities/string_utils.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/env/web_scheduler_environment_config.dart';
import 'package:mini_ginger_web/models/member_info.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mini_ginger_web/utilities/web_launch_util.dart';

class CoachingSessionConfirmationModel extends NavigationModel {
  final log = Logger("CoachingSessionConfirmationModel");

  static const String hsAppStoreLink = 'https://headspace.app.link/umd';
  static const String d2cCareLink = 'https://d2ccare.headspace.app.link/umd';
  LocalServiceAPI api;
  HSMemberInfo memberInfo;

  CoachingSessionConfirmationModel({this.api}) {
    api ??= serviceLocator.get<ServiceAPI>() as LocalServiceAPI;
  }

  String get companyName => api.companyName;
  String get companyImageUrl => api.companyImageUrl;
  String username;
  String email;
  List<String> privileges;

  DateTime scheduledTime;

  String get memberType => api.memberType;
  String get enrollmentFlow => api.enrollmentFlow;

  String get formattedSessionDate {
    return scheduledTime != null
        ? DateUtils.formatDate(scheduledTime, R.current.session_date_format)
        : null;
  }

  String get formattedSessionTime {
    return scheduledTime != null
        ? DateUtils.formatDate(scheduledTime, 'jm')
        : null;
  }

  String get stepOneDesc {
    var arg = StringUtils.isNotEmpty(email) ? ': $email' : '';
    return R.current.coaching_session_confirmation_step_1_description(arg);
  }

  bool get hasEapPrivilege =>
      privileges != null && privileges.contains("HEADSPACE_EAP");

  Future<void> load() async {
    busy = true;
    notifyListeners();
    try {
      memberInfo = await api.fetchMemberInfo(fetchRemote: false);
      username = memberInfo.name;
      email = memberInfo.email ?? '';
      privileges = memberInfo.privileges ?? [];
    } on GingerDetailedError catch (e, stacktrace) {
      log.severe("Loading member failed with: $e", e, stacktrace);
      _showErrorDialog(R.current.something_went_wrong);
    } on GingerStatusError catch (e, stacktrace) {
      log.severe("Time selection failed with: $e", e, stacktrace);
      _showErrorDialog(R.current.something_went_wrong);
    } on SocketException catch (_) {
      _showErrorDialog(R.current.no_network_try_again);
    } catch (e, stacktrace) {
      log.severe("Time selection failed to upload", e, stacktrace);
      _showErrorDialog(R.current.unknown_error_message);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _showErrorDialog(String message) {
    api.modalService.showImmediately(HSCustomAlertModal(
      body: message,
      actions: [
        AlertActionConfig(
          text: R.current.ok,
          onPressed: () {},
          isDefaultAction: true,
        )
      ],
    ));
  }

  Future<void> actionSubmit() async {
    if (memberType == 'D2C') {
      await redirectToD2CCareLink();
    } else {
      await downloadHeadspace();
    }
  }

  Future<void> redirectToD2CCareLink() async {
    metricsProvider.track(D2cCareOnboardingCloseTapped());
    var deviceLaunchUtil = serviceLocator.get<DeviceLaunchUtil>();
    await deviceLaunchUtil.launch(d2cCareLink);
  }

  Future<void> downloadHeadspace() async {
    metricsProvider.track(DownloadHeadspaceTapped());
    var deviceLaunchUtil = serviceLocator.get<DeviceLaunchUtil>();
    var canLaunchLink = await deviceLaunchUtil.canLaunch(hsAppStoreLink);
    if (!canLaunchLink) {
      showError(R.current.unknown_error_message);
      return;
    }
    await deviceLaunchUtil.launch(hsAppStoreLink);
  }

  void showError(String message) {
    api.modalService.showImmediately(HSCustomAlertModal(
      body: message,
      actions: [
        AlertActionConfig(
          text: R.current.ok,
          onPressed: null,
          isDefaultAction: true,
        )
      ],
    ));
  }

  Future<void> redirectToHeadspaceHub() async {
    var deviceLaunchUtil =
        serviceLocator.get<DeviceLaunchUtil>() as WebLaunchUtilImpl;
    var url =
        WebSchedulerEnvironment.current.type == EnvironmentType.WEB_STAGING
            ? 'https://b2b.staging.headspace.com/hub'
            : 'https://work.headspace.com/hub';
    unawaited(deviceLaunchUtil.launch(
      url,
      launchMode: LaunchMode.platformDefault,
      newTabOnWeb: true,
    ));
  }
}
