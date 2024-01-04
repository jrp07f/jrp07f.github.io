import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/ui/screens/dependents_success/dependents_success_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';
import '../../test_dependency_manager.dart';
import '../../widget_test_util.dart';

void main() {
  MetricsProvider metrics;

  setUpAll(() {
    registerFallbackValue(Event("eventName"));
  });

  setUp(() async {
    var launchUrl = Uri.parse(
        'http://localhost:63634/teen-clinical-escalation?workflow_hash=12314');
    var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
    await dependencyManager.init();
    metrics = serviceLocator.get<MetricsProvider>();
  });

  group('render tests', () {
    testWidgets('screen is rendered successfully', (tester) async {
      /// GIVEN
      var model = DependentsSuccessModelMock();
      when(() => model.busy).thenReturn(false);

      /// WHEN screen is launched
      await tester.pumpWidget(
        WidgetTestUtil.wrapWidgetWithMaterialApp(
          widget: DependentsSuccessScreen(model: model),
        ),
      );

      /// THEN screen is rendered
      expect(find.byType(DependentsSuccessScreen), findsOneWidget);

      /// THEN event is tracked
      verify(() => metrics.track(any(that: isA<DependentsSuccessViewed>()))).called(1);
    });
  });

  group('onTapEmailSupport tests', () {
    testWidgets('onTapEmailSupport is successful', (tester) async {
      /// GIVEN
      var model = DependentsSuccessModelMock();
      when(() => model.busy).thenReturn(false);

      /// GIVEN screen is launched
      await tester.pumpWidget(
        WidgetTestUtil.wrapWidgetWithMaterialApp(
          widget: DependentsSuccessScreen(model: model),
        ),
      );

      /// WHEN user taps email support
      WidgetTestUtil.fireOnTap(
        find.byKey(const Key('support_email')),
        R.current.team_support_email_address,
      );

      /// THEN event is tracked
      verify(() => metrics.track(any(that: isA<DependentsSuccessEmailSupportTapped>()))).called(1);
      verify(() => model.emailSupport()).called(1);
    });
  });

  group('onTapContinue tests', () {
    testWidgets('onTapContinue is successful', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(3000, 3000);
      /// GIVEN
      var model = DependentsSuccessModelMock();
      when(() => model.busy).thenReturn(false);

      /// GIVEN screen is launched
      await tester.pumpWidget(
        WidgetTestUtil.wrapWidgetWithMaterialApp(
          widget: DependentsSuccessScreen(model: model),
        ),
      );

      /// WHEN user taps cta
      await tester.tap(find.text(R.current.finish));

      /// THEN event is tracked
      verify(() => metrics.track(any(that: isA<DependentsSuccessFinishTapped>()))).called(1);
      verify(() => model.redirectToHeadspace()).called(1);
    });
  });
}
