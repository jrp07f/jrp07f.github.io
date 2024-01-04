import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/ui/screens/teen_clinical_escalation/teen_clinical_escalation_screen.dart';
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
      var model = FusionTeenClinicalEscalationModelMock();
      when(() => model.busy).thenReturn(false);

      /// WHEN screen is launched
      await tester.pumpWidget(
        WidgetTestUtil.wrapWidgetWithMaterialApp(
          widget: TeenClinicalEscalationScreen(model: model),
        ),
      );

      /// THEN screen is rendered
      expect(find.byType(TeenClinicalEscalationScreen), findsOneWidget);

      /// THEN event is tracked
      verify(() => metrics.track(any(that: isA<TeenClinicalEscalationViewed>()))).called(1);
    });
  });
}
