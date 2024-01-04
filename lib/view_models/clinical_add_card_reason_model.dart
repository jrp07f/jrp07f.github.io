import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/navigators/common_app_routes.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:care_dart_sdk/utilities/platform_util.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';

class ClinicalAddCardReasonModel extends NavigationModel {

  Future<void> actionPresentWebLink({String url, String pageTitle = ''}) async {
    if (url == null) return;

    var api = serviceLocator.get<ServiceAPI>();

    if(serviceLocator.get<PlatformUtil>().isWeb) {
      await openExternalTabForURL(url);
    }
    else {
      final args = WebviewSinglePageScreenArguments(
          title: pageTitle,
          url: url,
          dismiss: () {
            api.appRouter?.pop();
          });
      api?.appRouter?.pushNamed(
        CommonAppRoutes.webViewSinglePage,
        arguments: args,
      );
    }
  }

  Future<void> openExternalTabForURL(String url) async {
    final launchUtil = serviceLocator.get<DeviceLaunchUtil>();
    if (await launchUtil.canLaunch(url)) {
      await launchUtil.launch(url);
      return;
    }
  }

}
