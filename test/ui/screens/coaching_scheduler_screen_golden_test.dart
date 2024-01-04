import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/models/scheduler_slots.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/coaching_scheduler_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../device.dart';
import '../../golden_test_device_scenario.dart';
import '../../mocks.dart';
import '../../test_dependency_manager.dart';
import '../../widget_test_util.dart';

void main() async {
  setUpAll(() {
    registerFallbackValue(SchedulerTime(DateTime.now()));
  });

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
            for (var enrollmentFlow in enrollmentFlows) {
              var model = CoachingSchedulerModelMock();
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
                  when(() => model.busy).thenReturn(false);
                  when(() => model.shouldPresentErrorState).thenReturn(false);
                  when(() => model.hasAvailability).thenReturn(true);
                  when(() => model.timeZoneName).thenReturn('PDT');
                  when(() => model.visibleDateSlots).thenReturn([]);
                  when(() => model.visibleTimeSlots).thenReturn([]);
                  when(() => model.companyName).thenReturn('Company Name');
                  when(() => model.getSlotTitle(any())).thenReturn('foo');

                  return GoldenTestGroup(
                    children: [
                      GoldenTestDeviceScenario(
                        name: 'CoachingSchedulerScreen',
                        device: device,
                        builder: () {
                          return CoachingSchedulerScreen(model: model);
                        },
                      ),
                    ],
                  );
                },
                fileName:
                    '${device.name} $languageCode $enrollmentFlow CoachingSchedulerScreen',
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
                  // mock scheduler date and time here so that date formatting works
                  // initializing date formatting before the app is created throws
                  // an error causing the tests to fail
                  var startingDateTime = DateTime(2023, 9, 7, 10);
                  var timeSlots = 0;
                  when(() => model.getSlotTitle(any())).thenAnswer((_) {
                    timeSlots++;
                    return '${SchedulerTime(startingDateTime.add(Duration(minutes: timeSlots * 30))).timeOfDay}, PDT';
                  });
                  when(() => model.visibleDateSlots)
                      .thenReturn(List.generate(7, (index) {
                    return SchedulerDate(
                        startingDateTime.add(Duration(days: index)));
                  }));
                  when(() => model.visibleTimeSlots)
                      .thenReturn(List.generate(7, (index) {
                    return SchedulerTime(
                        startingDateTime.add(Duration(minutes: 30 * index)));
                  }));

                  await tester.pumpAndSettle();
                  await precacheImages(tester);
                },
                skip: !AlchemistConfig.current().platformGoldensConfig.enabled,
              );
            }
          });
        }
      }
    });
  }
}
