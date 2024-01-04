import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/models/scheduler_slots.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/coaching_scheduler_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';
import '../../test_dependency_manager.dart';
import '../../widget_test_util.dart';

void main() {
  MetricsProvider metrics;

  setUpAll(() {
    registerFallbackValue(Event("eventName"));
    registerFallbackValue(SchedulerTime(DateTime.now()));
  });

  setUp(() async {
    var launchUrl = Uri.parse('http://localhost:63634/?cname=Ginger&language=en&logo=');
    var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
    await dependencyManager.init();
    metrics = serviceLocator.get<MetricsProvider>();
  });

  group('render tests', () {
    testWidgets('screen is rendered successfully', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1024, 1366);

      // resets the screen to its original size after the test end
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      /// GIVEN
      var model = CoachingSchedulerModelMock();
      when(() => model.busy).thenReturn(false);
      when(() => model.shouldPresentErrorState).thenReturn(false);
      when(() => model.hasAvailability).thenReturn(true);
      when(() => model.visibleDateSlots).thenReturn([
        SchedulerDate(DateTime.now()),
        SchedulerDate(DateTime.now().add(const Duration(days: 1))),
        SchedulerDate(DateTime.now().add(const Duration(days: 2))),
      ]);
      when(() => model.visibleTimeSlots).thenReturn([
        SchedulerTime(DateTime.now()),
        SchedulerTime(DateTime.now().add(const Duration(hours: 1))),
        SchedulerTime(DateTime.now().add(const Duration(hours: 2))),
      ]);
      when(() => model.companyName).thenReturn('Company Name');
      when(() => model.getSlotTitle(any())).thenReturn('foo');

      /// WHEN screen is launched
      await tester.pumpWidget(
        WidgetTestUtil.wrapWidgetWithMaterialApp(
          widget: CoachingSchedulerScreen(model: model),
        ),
      );

      /// THEN screen is rendered
      expect(find.byType(CoachingSchedulerScreen), findsOneWidget);

      /// THEN event is tracked
      verify(() => metrics.track(any(that: isA<WebSchedulerViewed>()))).called(1);
    });
  });
}
