import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_dart_sdk/utilities/date_utils.dart' as care_sdk;
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/coaching_session_confirmation_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../device.dart';
import '../../golden_test_device_scenario.dart';
import '../../mocks.dart';
import '../../test_dependency_manager.dart';
import '../../widget_test_util.dart';

void main() async {
  var devices = [
    Device.smallPhone,
    Device.iphone11,
    Device.tabletPortrait,
    Device.tabletLandscape,
  ];

  var languageCodes = [
    'en',
    'es',
    'fr',
  ];

  var enrollmentFlows = [
    'fusion',
    'umd',
  ];

  for (var languageCode in languageCodes) {
    var locale = Locale(languageCode);
    group(languageCode, () {
      for (var device in devices) {
        for (var enrollmentFlow in enrollmentFlows) {
          var model = CoachingSessionConfirmationModelMock();

          group('enrollmentFlow: $enrollmentFlow', () {
            setUp(() async {
              var launchUrl = Uri.parse(
                  'http://localhost:63634/?cname=Ginger&language=$languageCode&logo=&enrollment_flow=$enrollmentFlow');
              var dependencyManager = TestDependencyManager(
                launchUrl: launchUrl,
                locale: locale,
                isGoldenTest: true,
              );
              await dependencyManager.init();
            });

            goldenTest(
              'renders ${device.name} $languageCode $enrollmentFlow correctly',
              builder: () {
                /// GIVEN
                when(() => model.scheduledTime)
                    .thenReturn(DateTime(2023, 2, 26));
                when(() => model.busy).thenReturn(false);
                when(() => model.companyName).thenReturn('Company Name');
                when(() => model.formattedSessionDate).thenReturn('');
                when(() => model.formattedSessionTime).thenReturn('');
                when(() => model.stepOneDesc).thenReturn(R.current
                    .coaching_session_confirmation_step_1_description(
                        'daveedcasal@gmail.com'));
                when(() => model.memberType).thenReturn(null);
                return GoldenTestGroup(
                  children: [
                    GoldenTestDeviceScenario(
                      name: 'CoachingSessionConfirmationScreen',
                      device: device,
                      builder: () {
                        return CoachingSessionConfirmationScreen(DateTime.now(),
                            model: model);
                      },
                    ),
                  ],
                );
              },
              fileName:
                  '${device.name} $languageCode $enrollmentFlow CoachingSessionConfirmationScreen',
              pumpWidget: (tester, widget) async {
                await tester.pumpWidget(
                  WidgetTestUtil.wrapWidgetWithMaterialApp(
                    widget: widget,
                    selectedLocale: Locale(languageCode),
                    isGoldenTest: true,
                  ),
                );
              },
              pumpBeforeTest: (tester) async {
                var scheduledTime = DateTime(2023, 2, 26, 10, 30);
                when(() => model.formattedSessionDate).thenReturn(
                    care_sdk.DateUtils.formatDate(
                        scheduledTime, R.current.session_date_format));
                when(() => model.formattedSessionTime).thenReturn(
                    care_sdk.DateUtils.formatDate(scheduledTime, 'jm'));

                await tester.pumpAndSettle();
                await precacheImages(tester);
              },
              skip: !AlchemistConfig.current().platformGoldensConfig.enabled,
            );
          });
        }
      }
    });
  }

  for (var languageCode in languageCodes) {
    var locale = Locale(languageCode);
    group(languageCode, () {
      for (var device in devices) {
        var model = CoachingSessionConfirmationModelMock();

        group('member_type: d2c', () {
          setUp(() async {
            var launchUrl = Uri.parse(
                'http://localhost:63634/?cname=Ginger&language=$languageCode&logo=&member_type=d2c');
            var dependencyManager = TestDependencyManager(
              launchUrl: launchUrl,
              locale: locale,
              isGoldenTest: true,
            );
            await dependencyManager.init();
          });

          goldenTest(
            'renders ${device.name} $languageCode fusion d2c correctly',
            builder: () {
              /// GIVEN
              when(() => model.scheduledTime).thenReturn(DateTime(2023, 2, 26));
              when(() => model.busy).thenReturn(false);
              when(() => model.companyName).thenReturn('Company Name');
              when(() => model.formattedSessionDate).thenReturn('');
              when(() => model.formattedSessionTime).thenReturn('');
              when(() => model.stepOneDesc).thenReturn(R.current
                  .coaching_session_confirmation_step_1_description(
                      'daveedcasal@gmail.com'));
              when(() => model.enrollmentFlow).thenReturn(null);
              when(() => model.memberType).thenReturn('D2C');
              return GoldenTestGroup(
                children: [
                  GoldenTestDeviceScenario(
                    name: 'CoachingSessionConfirmationScreen',
                    device: device,
                    builder: () {
                      return CoachingSessionConfirmationScreen(DateTime.now(),
                          model: model);
                    },
                  ),
                ],
              );
            },
            fileName:
                '${device.name} $languageCode fusion d2c CoachingSessionConfirmationScreen',
            pumpWidget: (tester, widget) async {
              await tester.pumpWidget(
                WidgetTestUtil.wrapWidgetWithMaterialApp(
                  widget: widget,
                  selectedLocale: Locale(languageCode),
                  isGoldenTest: true,
                ),
              );
            },
            pumpBeforeTest: (tester) async {
              var scheduledTime = DateTime(2023, 2, 26, 10, 30);
              when(() => model.formattedSessionDate).thenReturn(
                  care_sdk.DateUtils.formatDate(
                      scheduledTime, R.current.session_date_format));
              when(() => model.formattedSessionTime).thenReturn(
                  care_sdk.DateUtils.formatDate(scheduledTime, 'jm'));

              await tester.pumpAndSettle();
              await precacheImages(tester);
            },
            skip: !AlchemistConfig.current().platformGoldensConfig.enabled,
          );
        });
      }
    });
  }
}
