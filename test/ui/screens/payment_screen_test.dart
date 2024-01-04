import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/ui/screens/payment_screen/payment_screen.dart';
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
      var model = PaymentModelMock();
      when(() => model.busy).thenReturn(false);
      when(() => model.cardNumberText).thenReturn("•••• •••• •••• 1234");
      when(() => model.cardExpiryText).thenReturn("02/26");

      /// WHEN screen is launched
      await tester.pumpWidget(
        WidgetTestUtil.wrapWidgetWithMaterialApp(
          widget: PaymentScreen(model: model),
        ),
      );

      /// THEN screen is rendered
      expect(find.byType(PaymentScreen), findsOneWidget);

      /// THEN event is tracked
      verify(() => metrics.track(any(that: isA<PaymentViewed>()))).called(1);
    });
  });
}
