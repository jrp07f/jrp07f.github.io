import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/view_models/dependents_success_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher/url_launcher.dart';

import '../test_dependency_manager.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(LaunchMode.platformDefault);
  });

  setUp(() async {
    var launchUrl = Uri.parse(
        'http://localhost:63634/guardian-consent?workflow_hash=12314');
    var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
    await dependencyManager.init();
  });

  group('redirectToHeadspace tests', () {
    test('should call deviceLaunchUtil', () async {
      /// GIVEN
      var model = DependentsSuccessModel();
      var deviceLaunchUtil = serviceLocator.get<DeviceLaunchUtil>();

      /// WHEN
      model.redirectToHeadspace();

      /// THEN
      verify(() => deviceLaunchUtil.launch(any(), launchMode: any(named: 'launchMode'))).called(1);
    });
  });
}