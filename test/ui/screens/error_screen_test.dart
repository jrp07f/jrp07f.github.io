import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/ui/screens/error/error_screen.dart';
import '../../test_dependency_manager.dart';
import '../../widget_test_util.dart';

void main() {
  setUp(() async {
    var launchUrl = Uri.parse(
        'http://localhost:63634/guardian-consent?workflow_hash=12314');
    var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
    await dependencyManager.init();
  });

  group('render tests', () {
    testWidgets('screen is rendered successfully', (tester) async {
      /// WHEN screen is launched
      await tester.pumpWidget(
        WidgetTestUtil.wrapWidgetWithMaterialApp(
          widget: const ErrorScreen(),
        ),
      );

      /// THEN screen is rendered
      expect(find.byType(ErrorScreen), findsOneWidget);
    });
  });
}
