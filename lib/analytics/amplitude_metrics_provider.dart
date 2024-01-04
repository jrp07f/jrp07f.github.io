import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/utilities/string_utils.dart';
import 'package:mini_ginger_web/analytics/metrics.dart';

class AmplitudeMetricsProvider extends MetricsProvider {
  final Amplitude _amplitude;
  final LocalMetricsConfig localMetricsConfig;

  AmplitudeMetricsProvider(this._amplitude, {this.localMetricsConfig})
      : super(config: localMetricsConfig);

  /// Method for identifying tracked events by a user on Amplitude.
  @override
  Future<void> identify(dynamic userId) async {
    _amplitude.setUserId('$userId');

    Identify identify = Identify();
    identify.set("user_id", localMetricsConfig.metricsUserId);

    if (!StringUtils.isEmpty(localMetricsConfig.memberOrgName)) {
      identify.set("member_organization", localMetricsConfig.memberOrgName);
    }

    if (!StringUtils.isEmpty(localMetricsConfig.preferredLanguage)) {
      identify.set("preferred_language", localMetricsConfig.preferredLanguage);
    }

    identify.set("is_umd_member", true);

    _amplitude.identify(identify);
  }

  /// Method for preventing tracking events against a logged out user.
  @override
  void removeUser() {
    _amplitude.setUserId(null);
  }

  @override
  Future<void> executeTrack(Event event) async {
    var props = event.props;

    if (localMetricsConfig != null) {
      Map<String, dynamic> commonProps = await localMetricsConfig.commonProps();
      props.addAll(commonProps);
    }

    _amplitude.logEvent(
      event.eventName,
      eventProperties: props,
    );
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> props,
      {bool appendProps = false}) {
    // Do nothing
  }
}
