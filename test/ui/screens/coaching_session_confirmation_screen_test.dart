import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/coaching_session_confirmation_screen.dart';
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
    var launchUrl = Uri.parse('http://localhost:63634/?cname=Ginger&language=en&logo=');
    var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
    await dependencyManager.init();
    metrics = serviceLocator.get<MetricsProvider>();
  });

  group('render tests', () {
    testWidgets('screen is rendered successfully', (tester) async {
      /// GIVEN
      var model = CoachingSessionConfirmationModelMock();
      when(() => model.busy).thenReturn(false);
      when(() => model.companyName).thenReturn('Company Name');
      when(() => model.formattedSessionDate).thenReturn('');
      when(() => model.formattedSessionTime).thenReturn('');
      when(() => model.stepOneDesc).thenReturn(R.current.coaching_session_confirmation_step_1_description('daveedcasal@gmail.com'));
      when(() => model.enrollmentFlow).thenReturn('fusion');
      when(() => model.memberType).thenReturn(null);
      when(() => model.hasEapPrivilege).thenReturn(false);

      /// WHEN screen is launched
      await tester.pumpWidget(
        WidgetTestUtil.wrapWidgetWithMaterialApp(
          widget: CoachingSessionConfirmationScreen(DateTime.now(), model: model),
        ),
      );

      /// THEN screen is rendered
      expect(find.byType(CoachingSessionConfirmationScreen), findsOneWidget);
      /// THEN event is tracked
      verify(() => metrics.track(any(that: isA<CoachingSessionConfirmationViewedEvent>()))).called(1);
    });

    testWidgets('screen is rendered successfully', (tester) async {
      /// GIVEN
      var model = CoachingSessionConfirmationModelMock();
      when(() => model.busy).thenReturn(false);
      when(() => model.companyName).thenReturn('Company Name');
      when(() => model.formattedSessionDate).thenReturn('');
      when(() => model.formattedSessionTime).thenReturn('');
      when(() => model.stepOneDesc).thenReturn(R.current.coaching_session_confirmation_step_1_description('daveedcasal@gmail.com'));
      when(() => model.enrollmentFlow).thenReturn('umd');
      when(() => model.memberType).thenReturn(null);
      when(() => model.hasEapPrivilege).thenReturn(false);

      /// WHEN screen is launched
      await tester.pumpWidget(
        WidgetTestUtil.wrapWidgetWithMaterialApp(
          widget: CoachingSessionConfirmationScreen(DateTime.now(), model: model),
        ),
      );

      /// THEN screen is rendered
      expect(find.byType(CoachingSessionConfirmationScreen), findsOneWidget);
      /// THEN event is tracked
      verify(() => metrics.track(any(that: isA<CoachingSessionConfirmationViewedEvent>()))).called(1);
    });
  });

  group('onSubmitTapped', () {
    testWidgets('onSubmitTapped calls model.downloadHeadspace()', (tester) async {
      /// GIVEN
      var model = CoachingSessionConfirmationModelMock();
      when(() => model.busy).thenReturn(false);
      when(() => model.companyName).thenReturn('Company Name');
      when(() => model.formattedSessionDate).thenReturn('');
      when(() => model.formattedSessionTime).thenReturn('');
      when(() => model.stepOneDesc).thenReturn(R.current.coaching_session_confirmation_step_1_description('daveedcasal@gmail.com'));
      when(() => model.enrollmentFlow).thenReturn('fusion');
      when(() => model.memberType).thenReturn(null);
      when(() => model.hasEapPrivilege).thenReturn(false);
      /// GIVEN screen is launched
      await tester.pumpWidget(
        WidgetTestUtil.wrapWidgetWithMaterialApp(
          widget: CoachingSessionConfirmationScreen(DateTime.now(), model: model),
        ),
      );

      /// WHEN submit button is tapped
      await tester.scrollUntilVisible(find.byKey(const ValueKey('DownloadHeadspaceButton')), 500);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('DownloadHeadspaceButton')));

      /// THEN model.downloadHeadspace() is called
      verify(() => model.actionSubmit()).called(1);
    });
  });

  group('onEapCtaTapped', () {
    testWidgets('onEapCtaTapped calls model.redirectToHeadspaceHub()',
        (tester) async {
      /// GIVEN
      var model = CoachingSessionConfirmationModelMock();
      when(() => model.busy).thenReturn(false);
      when(() => model.companyName).thenReturn('Company Name');
      when(() => model.formattedSessionDate).thenReturn('');
      when(() => model.formattedSessionTime).thenReturn('');
      when(() => model.hasEapPrivilege).thenReturn(true);
      when(() => model.stepOneDesc).thenReturn(R.current
          .coaching_session_confirmation_step_1_description(
              'daveedcasal@gmail.com'));
      when(() => model.enrollmentFlow).thenReturn('fusion');
      when(() => model.memberType).thenReturn(null);

      /// GIVEN screen is launched
      await tester.pumpWidget(
        WidgetTestUtil.wrapWidgetWithMaterialApp(
          widget:
              CoachingSessionConfirmationScreen(DateTime.now(), model: model),
        ),
      );

      /// WHEN redirect button is tapped
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('HeadspaceHubRedirectButton')), 500);
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const ValueKey('HeadspaceHubRedirectButton')));

      verify(() => model.redirectToHeadspaceHub()).called(1);
    });
  });

}