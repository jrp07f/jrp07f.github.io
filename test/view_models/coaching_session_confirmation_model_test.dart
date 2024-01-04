import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/modals/modal_alert_dialog.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:mini_ginger_web/view_models/coaching_session_confirmation_model.dart';
import 'package:mocktail/mocktail.dart';

import '../test_dependency_manager.dart';

void main() async {
  LocalServiceAPI api;
  MetricsProvider metrics;
  DeviceLaunchUtil deviceLaunchUtil;

  setUp(() async {
    var launchUrl =
        Uri.parse('http://localhost:63634/?cname=Ginger&language=en&logo=');
    var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
    await dependencyManager.init();
    api = serviceLocator.get<ServiceAPI>() as LocalServiceAPI;
    metrics = serviceLocator.get<MetricsProvider>();
    deviceLaunchUtil = serviceLocator.get<DeviceLaunchUtil>();
  });

  group('actionSubmit tests', () {
    test('should track D2cCareOnboardingCloseTapped', () async {
      /// GIVEN
      var model = CoachingSessionConfirmationModel();
      api.enrollmentFlow = 'umd';
      api.memberType = 'D2C';

      /// WHEN
      await model.actionSubmit();

      /// THEN
      verify(() =>
              metrics.track(any(that: isA<D2cCareOnboardingCloseTapped>())))
          .called(1);
      /// THEN deviceLaunchUtil is called
      verify(() => deviceLaunchUtil.launch(
          CoachingSessionConfirmationModel.d2cCareLink,
          launchMode: any(named: 'launchMode'))).called(1);
    });

    test('should track DownloadHeadspaceTapped when enrollment flow is umd',
        () async {
      /// GIVEN
      var model = CoachingSessionConfirmationModel();
      api.enrollmentFlow = 'umd';
      api.memberType = null;

      /// WHEN
      await model.actionSubmit();

      /// THEN event is tracked
      verify(() => metrics.track(any(that: isA<DownloadHeadspaceTapped>())))
          .called(1);

      /// THEN deviceLaunchUtil is called
      verify(() => deviceLaunchUtil.launch(
          CoachingSessionConfirmationModel.hsAppStoreLink,
          launchMode: any(named: 'launchMode'))).called(1);
    });

    test('should track DownloadHeadspaceTapped when enrollment flow is fusion',
        () async {
      /// GIVEN
      var model = CoachingSessionConfirmationModel();
      api.enrollmentFlow = 'fusion';
      api.memberType = null;

      /// WHEN
      await model.actionSubmit();

      /// THEN event is tracked
      verify(() => metrics.track(any(that: isA<DownloadHeadspaceTapped>())))
          .called(1);

      /// THEN deviceLaunchUtil is called
      verify(() => deviceLaunchUtil.launch(
          CoachingSessionConfirmationModel.hsAppStoreLink,
          launchMode: any(named: 'launchMode'))).called(1);
    });
  });

  group('showError tests', () {
    test('should call modalService', () async {
      // GIVEN model
      var model = CoachingSessionConfirmationModel();

      // WHEN showError() is called
      model.showError(R.current.unknown_error_message);

      // THEN modalService should be called
      verify(() => api.modalService.showImmediately(
            any(that: isInstanceOf<HSCustomAlertModal>()),
          )).called(1);
    });
  });
}
