import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:flutter_test/flutter_test.dart';
import '../fixtures/ginger_http_fixtures.dart';
import '../test_dependency_manager.dart';
import "package:http/http.dart" as http;

void main() {
  group('Network Response tests', () {
    setUp(() async {
      var launchUrl = Uri.parse(
          'http://localhost:63634/guardian-consent?workflow_hash=12314');
      var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
      await dependencyManager.init();
    });

    group('GingerCredentialResponse tests', () {
      test('parse ginger credentials should have server secret', () async {
        // GIVEN successful ginger credentials response
        var response = http.Response(GingerHttpFixtures.credentialsResponse, 200);

        // WHEN we parse the response.
        final result = GingerCredentialResponse.fromJSON(response);

        // THEN we should receive an accurate success response.
        expect(result.httpStatusCode, 200);
        expect(result.responseBody, response.body);
        expect(result.userId != 0, isTrue);
        expect(result.serverSecret, isNotNull);
      });
    });
  });
}
