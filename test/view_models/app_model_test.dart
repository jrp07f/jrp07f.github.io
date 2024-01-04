import 'package:care_dart_sdk/services/network_service/http_response_matcher.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/commons/storage_keys.dart';
import 'package:mini_ginger_web/navigation/app_routes.dart';
import 'package:mini_ginger_web/view_models/app_model.dart';

import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import '../fixtures/ginger_http_fixtures.dart';
import '../mocks.dart';
import '../test_dependency_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppModel tests', () {
    group('continueLaunch', () {
      group('redirect to guardianConsent', () {
        test(
            'launch guardianConsent screen if launchUrl is set to guardianConsent',
            () async {
          // GIVEN launchUrl is set to guardianConsent
          var launchUrl = Uri.parse(
              'http://localhost:63634/guardian-consent?workflow_hash=12314');
          var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
          await dependencyManager.init();

          // GIVEN authentication succeeds
          HttpResponseMatcher httpResponseMatcher =
              serviceLocator.get<HttpResponseMatcher>();
          httpResponseMatcher.insert((path, method, params) {
            if (path.contains('/user-details')) {
              return Response(GingerHttpFixtures.userResponse(), 200);
            }
            if (path.contains('mobile-api/v2/workflows/')) {
              return Response(
                  GingerHttpFixtures
                      .fusionGuardianWorkflowResponseWithLearnStatus,
                  200);
            }
            return null;
          });

          // GIVEN model
          var model = MainAppModel();
          model.router = RouterMock();

          // WHEN continueLaunch() is called
          await model.continueLaunch();

          // THEN router should push guardianConsent screen
          verify(() => model.router.pushNamedAndRemoveAll(
            AppRoutes.guardianConsent,
            arguments: any(named: 'arguments'),
          )).called(1);
        });

        test(
            'launch guardianConsent screen if launchUrl is blank but workflowHash is stored',
            () async {
          // GIVEN launchUrl is empty
          var launchUrl = Uri.parse('http://localhost:63634');
          var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
          await dependencyManager.init();

          // GIVEN local storage has workflowHash stored
          await serviceLocator.ensureReady<FlutterSecureStorage>();
          var storage = serviceLocator.get<FlutterSecureStorage>();
          storage.write(key: StorageKeys.kWorkflowHash, value: '12345');
          // GIVEN authentication succeeds
          HttpResponseMatcher httpResponseMatcher =
              serviceLocator.get<HttpResponseMatcher>();
          httpResponseMatcher.insert((path, method, params) {
            if (path.contains('/user-details')) {
              return Response(GingerHttpFixtures.userResponse(), 200);
            }
            if (path.contains('mobile-api/v2/workflows/')) {
              return Response(
                  GingerHttpFixtures
                      .fusionGuardianWorkflowResponseWithLearnStatus,
                  200);
            }
            return null;
          });

          // GIVEN model
          var model = MainAppModel();
          model.router = RouterMock();

          // WHEN continueLaunch() is called
          await model.continueLaunch();

          // THEN router should push guardianConsent screen
          verify(() => model.router.pushNamedAndRemoveAll(
            AppRoutes.guardianConsent,
            arguments: any(named: 'arguments'),
          )).called(1);
        });
      });

      group('redirect to teenClinicalEscalation', () {
        test(
            'launch teenClinicalEscalation screen if launchUrl is set to teenClinicalEscalation',
            () async {
          // GIVEN launchUrl is set to guardianConsent
          var launchUrl = Uri.parse(
              'http://localhost:63634/teen-clinical-escalation?workflow_hash=12314');
          var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
          await dependencyManager.init();

          // GIVEN authentication succeeds
          HttpResponseMatcher httpResponseMatcher =
              serviceLocator.get<HttpResponseMatcher>();
          httpResponseMatcher.insert((path, method, params) {
            if (path.contains('/user-details')) {
              return Response(GingerHttpFixtures.userResponse(), 200);
            }
            if (path.contains('mobile-api/v2/workflows/')) {
              return Response(
                  GingerHttpFixtures
                      .fusionTeenClinicalEscalationWorkflowResponseWithIntakePendingStatus,
                  200);
            }
            return null;
          });

          // GIVEN model
          var model = MainAppModel();
          model.router = RouterMock();

          // WHEN continueLaunch() is called
          await model.continueLaunch();

          // THEN router should push teenClinicalEscalation screen
          verify(() => model.router.pushNamedAndRemoveAll(
            AppRoutes.teenClinicalEscalation,
            arguments: any(named: 'arguments'),
          )).called(1);
        });

        test(
            'launch teenClinicalEscalation screen if launchUrl is blank but workflowHash is stored',
            () async {
          // GIVEN launchUrl is empty
          var launchUrl = Uri.parse('http://localhost:63634');
          var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
          await dependencyManager.init();

          // GIVEN local storage has workflowHash stored
          await serviceLocator.ensureReady<FlutterSecureStorage>();
          var storage = serviceLocator.get<FlutterSecureStorage>();
          storage.write(key: StorageKeys.kWorkflowHash, value: '12345');
          // GIVEN authentication succeeds
          HttpResponseMatcher httpResponseMatcher =
              serviceLocator.get<HttpResponseMatcher>();
          httpResponseMatcher.insert((path, method, params) {
            if (path.contains('/user-details')) {
              return Response(GingerHttpFixtures.userResponse(), 200);
            }
            if (path.contains('mobile-api/v2/workflows/')) {
              return Response(
                  GingerHttpFixtures
                      .fusionTeenClinicalEscalationWorkflowResponseWithIntakePendingStatus,
                  200);
            }
            return null;
          });

          // GIVEN model
          var model = MainAppModel();
          model.router = RouterMock();

          // WHEN continueLaunch() is called
          await model.continueLaunch();

          // THEN router should push guardianConsent screen
          verify(() => model.router.pushNamedAndRemoveAll(
            AppRoutes.teenClinicalEscalation,
            arguments: any(named: 'arguments'),
          )).called(1);
        });
      });

      test(
          'launch error screen if workflowHash is not empty but authentication fails',
          () async {
        // GIVEN launchUrl is empty
        var launchUrl = Uri.parse('http://localhost:63634');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // GIVEN local storage has workflowHash stored
        await serviceLocator.ensureReady<FlutterSecureStorage>();
        // GIVEN authentication fails
        HttpResponseMatcher httpResponseMatcher =
            serviceLocator.get<HttpResponseMatcher>();
        httpResponseMatcher.insert((path, method, params) {
          if (path.contains('/user-details')) {
            throw Exception('Authentication failed');
          }
          return null;
        });

        var storage = serviceLocator.get<FlutterSecureStorage>();
        storage.write(key: StorageKeys.kWorkflowHash, value: '12345');

        // GIVEN model
        var model = MainAppModel();
        model.router = RouterMock();

        // WHEN continueLaunch() is called
        await model.continueLaunch();

        // THEN router should push error screen
        verify(() => model.router.pushNamedAndRemoveAll(
          AppRoutes.error,
          arguments: any(named: 'arguments'),
        )).called(1);
      });

      group('redirect to scheduler', () {
        test('launch scheduler screen if launch url is set to web scheduler',
            () async {
          // GIVEN launch url is set to web scheduler
          var launchUrl = Uri.parse(
              'http://localhost:63634/?cname=Ginger&language=en&logo=');
          var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
          await dependencyManager.init();

          // GIVEN model
          var model = MainAppModel();
          model.router = RouterMock();

          // WHEN continueLaunch() is called
          await model.continueLaunch();

          // THEN router should push scheduler screen
          verify(() => model.router.pushNamedAndRemoveAll(
            AppRoutes.scheduler,
            arguments: any(named: 'arguments'),
          )).called(1);
        });

        test(
            'launch scheduler screen if launchUrl is blank but workflow hash is not stored',
            () async {
          // GIVEN launchUrl is empty
          var launchUrl = Uri.parse('http://localhost:63634');
          var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
          await dependencyManager.init();

          // GIVEN local storage does not have workflowHash stored

          // GIVEN model
          var model = MainAppModel();
          model.router = RouterMock();

          // WHEN continueLaunch() is called
          await model.continueLaunch();

          // THEN router should push scheduler screen
          verify(() => model.router.pushNamedAndRemoveAll(
            AppRoutes.scheduler,
            arguments: any(named: 'arguments'),
          )).called(1);
        });
      });
    });

    group('enrollmentFlow', () {
      test(
          'enrollmentFlow is fusion if launch url contains enrollment_flow param = fusion',
          () async {
        // GIVEN launch url is set to web scheduler
        var launchUrl =
            Uri.parse('http://localhost:63634/?enrollment_flow=fusion');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // WHEN enrollmentFlow is fetched
        var enrollmentFlow =
        await serviceLocator.getAsync<String>(instanceName: 'enrollmentFlow');

        // THEN enrollmentFlow is fusion
        expect(enrollmentFlow, 'fusion');
      });

      test(
          'enrollmentFlow is fusion if launch url contains member_type param = D2C',
          () async {
        // GIVEN launch url is set to web scheduler
        var launchUrl =
            Uri.parse('http://localhost:63634/?member_type=D2C');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // WHEN enrollmentFlow is fetched
        var enrollmentFlow = await serviceLocator.getAsync<String>(
            instanceName: 'enrollmentFlow');

        // THEN enrollmentFlow is fusion
        expect(enrollmentFlow, 'fusion');
      });

      test(
          'enrollmentFlow is fusion if launch url does not contain fusion member param but local storage has it stored',
          () async {
        // GIVEN launchUrl is empty
        var launchUrl = Uri.parse('http://localhost:63634');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // GIVEN local storage has enrollmentFlow stored
        await serviceLocator.ensureReady<FlutterSecureStorage>();
        var storage = serviceLocator.get<FlutterSecureStorage>();
        await storage.write(key: StorageKeys.kEnrollmentFlow, value: 'fusion');

        // WHEN enrollmentFlow is fetched
        var enrollmentFlow =
        await serviceLocator.getAsync<String>(instanceName: 'enrollmentFlow');

        // THEN enrollmentFlow is fusion
        expect(enrollmentFlow, 'fusion');
      });

      test(
          'enrollmentFlow is umd if launch url contains enrollment_flow param = umd',
          () async {
        // GIVEN launch url is set to web scheduler
        var launchUrl =
            Uri.parse('http://localhost:63634/?enrollment_flow=umd');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // WHEN enrollmentFlow is fetched
        var enrollmentFlow =
        await serviceLocator.getAsync<String>(instanceName: 'enrollmentFlow');

        // THEN enrollmentFlow is umd
        expect(enrollmentFlow, 'umd');
      });

      test(
          'enrollmentFlow is headspace if launch url contains enrollment_flow param = headspace',
          () async {
        // GIVEN launch url is set to web scheduler
        var launchUrl =
            Uri.parse('http://localhost:63634/?enrollment_flow=headspace');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // WHEN enrollmentFlow is fetched
        var enrollmentFlow =
        await serviceLocator.getAsync<String>(instanceName: 'enrollmentFlow');

        // THEN enrollmentFlow is headspace
        expect(enrollmentFlow, 'headspace');
      });

      test(
          'enrollmentFlow is connected if launch url contains enrollment_flow param = connected',
          () async {
        // GIVEN launch url is set to web scheduler
        var launchUrl =
            Uri.parse('http://localhost:63634/?enrollment_flow=connected');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // WHEN enrollmentFlow is fetched
        var enrollmentFlow =
        await serviceLocator.getAsync<String>(instanceName: 'enrollmentFlow');

        // THEN enrollmentFlow is connected
        expect(enrollmentFlow, 'connected');
      });

      test(
          'enrollmentFlow is unknown if launch url contains enrollment_flow param = unknown',
          () async {
        // GIVEN launch url is set to web scheduler
        var launchUrl =
            Uri.parse('http://localhost:63634/?enrollment_flow=unknown');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // WHEN enrollmentFlow is fetched
        var enrollmentFlow =
        await serviceLocator.getAsync<String>(instanceName: 'enrollmentFlow');

        // THEN enrollmentFlow is unknown
        expect(enrollmentFlow, 'unknown');
      });

      test(
          'enrollmentFlow is unknown text if launch url does not contain fusion member param',
          () async {
        // GIVEN launchUrl is empty
        var launchUrl = Uri.parse('http://localhost:63634');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // WHEN enrollmentFlow is fetched
        var enrollmentFlow =
            await serviceLocator.getAsync<String>(instanceName: 'enrollmentFlow');

        // THEN enrollmentFlow is unknown
        expect(enrollmentFlow, 'unknown');
      });
    });

    group('memberType', () {
      test(
          'memberType is D2C if launch url contains member_type param = D2C',
          () async {
        // GIVEN launch url is set to web scheduler
        var launchUrl =
            Uri.parse('http://localhost:63634/?member_type=D2C');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // WHEN memberType is fetched
        var memberType = await serviceLocator.getAsync<String>(
            instanceName: 'memberType');

        // THEN memberType is D2C
        expect(memberType, 'D2C');
      });

      test(
          'memberType is empty string if launch url DOES NOT contain member_type param',
          () async {
        // GIVEN launch url is set to web scheduler
        var launchUrl = Uri.parse('http://localhost:63634/');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // WHEN memberType is fetched
        var memberType = await serviceLocator.getAsync<String>(
            instanceName: 'memberType');

        // THEN memberType is empty
        expect(memberType, '');
      });

      test(
          'memberType is D2C if launch url does not contain member_type param but local storage has it stored',
          () async {
        // GIVEN launchUrl is empty
        var launchUrl = Uri.parse('http://localhost:63634');
        var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
        await dependencyManager.init();

        // GIVEN local storage has memberType stored
        await serviceLocator.ensureReady<FlutterSecureStorage>();
        var storage = serviceLocator.get<FlutterSecureStorage>();
        await storage.write(key: StorageKeys.kMemberType, value: 'D2C');

        // WHEN memberType is fetched
        var memberType = await serviceLocator.getAsync<String>(
            instanceName: 'memberType');

        // THEN memberType is D2C
        expect(memberType, 'D2C');
      });
    });
  });
}
