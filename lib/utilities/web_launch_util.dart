import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:care_dart_sdk/utilities/platform_util.dart';
import 'package:care_dart_sdk/utilities/string_utils.dart';
import 'package:care_dart_sdk/utilities/window_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// Concrete implementation of the [DeviceLaunchUtil] abstract class.
class WebLaunchUtilImpl extends DeviceLaunchUtil {
  @override
  Future<bool> canLaunch(String urlString) async {
    return LaunchUtil.telOrHttpLinkCanLaunch(urlString);
  }

  @override
  Future<bool> launch(String urlString, {LaunchMode launchMode, bool newTabOnWeb = true}) {
    var url = Uri.tryParse(urlString);
    return launchUrl(
      url,
      mode: launchMode ?? LaunchMode.platformDefault,
      webOnlyWindowName: newTabOnWeb ? '_blank' : '_self',
    );
  }

  @override
  Future<void> launchTelephone(String phoneNumber) async {
    if (StringUtils.isEmpty(phoneNumber)) return;

    var phoneUri = "tel:$phoneNumber";
    if (serviceLocator.get<PlatformUtil>().isWeb) {
      WindowUtils.openTelephone(phoneUri);
    } else {
      if (serviceLocator
          .get<ServiceAPI>()
          .testVerifier
          .verifyMaybeExit("telOrHttpLinkCanLaunch")) return;

      if (await LaunchUtil.telOrHttpLinkCanLaunch(phoneUri)) {
        await launch(phoneUri);
      }
    }
  }
}