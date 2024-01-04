import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/modals/modal_alert_dialog.dart';
import 'package:care_dart_sdk/utilities/deeplink.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/navigation/app_routes.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:mini_ginger_web/utilities/web_launch_util.dart';
import 'package:mini_ginger_web/view_models/fusion_teen_clinical_escalation_model.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';
import '../test_dependency_manager.dart';

void main() {
  DeepLinkService deeplinkService;
  WebLaunchUtilImpl deviceLaunchUtil;
  LocalServiceAPI api;

  setUpAll(() {
    registerFallbackValue(FakeModalWidget());
  });

  setUp(() async {
    var launchUrl = Uri.parse(
        'http://localhost:63634/teen-clinical-escalation?workflow_hash=12314');
    var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
    await dependencyManager.init();
    deeplinkService = serviceLocator.get<DeepLinkService>();
    deviceLaunchUtil = serviceLocator.get<DeviceLaunchUtil>() as WebLaunchUtilImpl;
    api = serviceLocator.get<ServiceAPI>() as LocalServiceAPI;
  });

  group('handle(workflow) tests', () {
    test('handle FusionTeenClinicalEscalationIntakePendingStatus', () async {
      // GIVEN model
      var model = FusionTeenClinicalEscalationModel();
      var workflow = FusionWorkflow(
        id: 123,
        version: 456,
        status: FusionTeenClinicalEscalationIntakePendingStatus(
          deeplink: DeepLink(Uri.parse('gingerio://content?assignment=1212')),
          clinicianNeed: 'Therapy',
        ),
      );

      // WHEN handle(workflow) is called
      model.handle(workflow);

      // THEN deeplink event is added on postOnboardEvents
      verify(() => deeplinkService.postOnboardEvents).called(1);
    });

    test('handle FusionTeenClinicalEscalationDeclinedStatus status', () async {
      // GIVEN model
      var model = FusionTeenClinicalEscalationModel();
      var workflow = FusionWorkflow(
        id: 123,
        version: 456,
        status: FusionTeenClinicalEscalationDeclinedStatus(
          deeplink: DeepLink(Uri.parse('gingerio://content?assignment=1212')),
          clinicianNeed: 'Therapy',
        ),
      );

      // WHEN handle(workflow) is called
      model.handle(workflow);

      // THEN deviceLaunchUtil should redirect to headspace site
      verify(() => deviceLaunchUtil.launch('https://headspace.com', newTabOnWeb: false)).called(1);
    });

    test('handle FusionTeenClinicalEscalationAuthorizePaymentStatus', () async {
      // GIVEN model
      var model = FusionTeenClinicalEscalationModel();
      var workflow = FusionWorkflow(
        id: 123,
        version: 456,
        status: FusionTeenClinicalEscalationAuthorizePaymentStatus(
          action: 'authorize_payment',
        ),
      );

      // WHEN handle(workflow) is called
      model.handle(workflow);

      // THEN router should redirect to paymentScreen
      verify(() => api.appRouter.pushNamed(
            AppRoutes.paymentScreen,
            arguments: any(named: 'arguments', that: isA<AddCardScreenArg>()),
          )).called(1);
    });

    test('handle FusionTeenClinicalEscalationScheduleAppointmentStatus', () async {
      // GIVEN model
      var model = FusionTeenClinicalEscalationModel();
      var workflow = FusionWorkflow(
        id: 123,
        version: 456,
        status: FusionTeenClinicalEscalationScheduleAppointmentStatus(
          clinicianNeed: 'Therapy',
        ),
      );

      // WHEN handle(workflow) is called
      model.handle(workflow);

      // THEN router should redirect to dependentsSuccess
      verify(() => api.appRouter.pushNamed(AppRoutes.dependentsSuccess))
          .called(1);
    });

    test('handle FusionTeenClinicalEscalationReadyStatus', () async {
      // GIVEN model
      var model = FusionTeenClinicalEscalationModel();
      var workflow = FusionWorkflow(
        id: 123,
        version: 456,
        status: FusionTeenClinicalEscalationReadyStatus(
          clinicianNeed: 'Therapy',
        ),
      );

      // WHEN handle(workflow) is called
      model.handle(workflow);

      // THEN router should redirect to dependentsSuccess
      verify(() => api.appRouter.pushNamed(AppRoutes.dependentsSuccess))
          .called(1);
    });
  });

  group('showErrorDialog tests', () {
    test('should call modalService', () async {
      // GIVEN model
      var model = FusionTeenClinicalEscalationModel();
      var api = serviceLocator.get<ServiceAPI>();

      // WHEN showErrorDialog() is called
      model.showErrorDialog('foo');

      // THEN modalService should be called
      verify(() => api.modalService.showImmediately(
        any(that: isInstanceOf<HSCustomAlertModal>()),
      )).called(1);
    });
  });
}
