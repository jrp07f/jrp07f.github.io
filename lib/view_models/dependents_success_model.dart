import 'dart:async';

import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/services/modal_service.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/modals/modal_alert_dialog.dart';
import 'package:care_dart_sdk/ui/shared/ginger_alert_dialog.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:mini_ginger_web/utilities/web_launch_util.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

class DependentsSuccessModel extends NavigationModel {
  final log = Logger('FusionGuardianIntakeModel');

  void emailSupport() {
    LaunchUtil.launchEmail(
      emailAddress: R.current.team_support_email_address,
      subject: R.current.guardian_consent_team_support_email_title,
      onError: () {
        showMessageDialog();
      },
    );
  }

  void showMessageDialog() {
    var modalService = serviceLocator.get<ModalService>();

    modalService.showImmediately(
      HSCustomAlertModal(
        body: R.current.contact_help_email_launch_failed,
        actions: [
          AlertActionConfig(
            text: R.current.ok,
          ),
        ],
      ),
    );
  }

  void redirectToHeadspace() {
    var deviceLaunchUtil = serviceLocator.get<DeviceLaunchUtil>() as WebLaunchUtilImpl;
    unawaited(deviceLaunchUtil.launch(
      'https://headspace.com',
      launchMode: LaunchMode.platformDefault,
      newTabOnWeb: true,
    ));
  }
}