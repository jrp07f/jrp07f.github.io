import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/utilities/app_metadata_util.dart';
import 'package:flutter/foundation.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LocalAppMetaData extends AppMetaData {
  LocalAppMetaData({@required PackageInfo packageInfo}): super(packageInfo: packageInfo);

  String get appName => packageInfo.appName;

  String get packageName => packageInfo.packageName;

  String get version => packageInfo.version;

  String get buildNumber => packageInfo.buildNumber;

  @override
  Map<String, String> getPackageInfoMap() {
    Map<String, String> data = {};

    data['appName'] = appName;
    data['packageName'] = packageName;
    data['version'] = version;
    data['buildNumber'] = buildNumber;

    return data;
  }

  @override
  Map<String, String> getAboutInfo() {
    Map<String, String> data = {};

    data['version'] = version;
    data['buildNumber'] = buildNumber;

    String userId = (serviceLocator.get<ServiceAPI>() as LocalServiceAPI).hsUserId;

    data['userId'] = userId.toString();

    return data;
  }
}
