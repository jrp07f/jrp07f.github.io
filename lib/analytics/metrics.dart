import 'package:care_dart_sdk/analytics/metrics.dart';
import 'package:care_dart_sdk/models/tz_provider.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/utilities/device_info_provider.dart';

///Config is responsible for initial and current data being used by event
///trackers
class LocalMetricsConfig extends MetricsConfig {
  String preferredLanguage;

  LocalMetricsConfig(
      {dynamic metricsUserId,
      String memberOrgName,
      DeviceInfoProvider deviceInfoProvider,
      this.preferredLanguage,}) : super(
      metricsUserId: metricsUserId,
      memberOrgName: memberOrgName
  );

  Future<Map<String, dynamic>> commonProps() async {
    Map<String, dynamic> commonProps = {};

    commonProps['timezone'] = serviceLocator.get<TZProvider>()?.deviceTimeZone;

    if (metricsUserId != null) {
      commonProps['user_id'] = metricsUserId;
    }

    if (memberOrgName != null) {
      commonProps['member_organization'] = memberOrgName;
    }

    if (preferredLanguage != null) {
      commonProps['preferred_language'] = preferredLanguage;
    }

    commonProps['network'] = await detector.getConnectionType();
    commonProps['device_model'] = deviceInfoProvider.deviceModel;
    commonProps['is_umd_member'] = true;

    return commonProps;
  }
}