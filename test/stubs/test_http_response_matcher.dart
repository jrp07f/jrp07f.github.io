import 'dart:async';

import 'package:care_dart_sdk/services/maintenance_service.dart';
import 'package:flutter/foundation.dart';
import 'package:care_dart_sdk/services/network_service/http_response_matcher.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../fixtures/app_maintenance_fixtures.dart';
import '../fixtures/ginger_http_fixtures.dart';
import '../fixtures/headspace_http_fixtures.dart';
import '../fixtures/listener_http_fixtures.dart';

/// Response matcher that allows you to return an [Response] object
/// based upon path, method and params with easy matchers override
/// functionality.
class TestHttpResponseMatcher extends HttpResponseMatcher {
  List<ResponseMatcher> matchers = [];

  /// We set BASE responses here and overrides will be declared via [insert].
  /// This will be widely used in tests which requires server endpoint calls
  /// that we want to mock.
  ///
  /// A tip for prioritizing the matchers is that broader matches like
  /// path.contains("content") should be declared lowest in the priority so that
  /// more specific matches like path.contains("content/bookmarks") would be first
  /// on the lookup. This way, the broader matcher won't overtake the specific ones.
  TestHttpResponseMatcher() {
    /// Add the default matchers
    matchers.add(
      ((String path, String method, Map<String, dynamic> params) async {
        if (path.contains(MaintenanceService.PROD_MAINTENANCE_SCHEDULE_URL) ||
            path.contains(
              MaintenanceService.STAGING_MAINTENANCE_SCHEDULE_URL,
            )) {
          var alertStart = DateFormat('yyyy-MM-ddThh:mm:ss').format(
            DateTime.now().subtract(Duration(days: 1)),
          );
          var maintenanceStart = DateFormat('yyyy-MM-ddThh:mm:ss').format(
            DateTime.now().add(Duration(days: 1)),
          );
          var maintenanceEnd = DateFormat('yyyy-MM-ddThh:mm:ss').format(
            DateTime.now().add(Duration(days: 1, hours: 4)),
          );
          return Response(
            AppMaintenanceFixtures.downloadResponse(
              alertStart: alertStart,
              maintenanceStart: maintenanceStart,
              maintenanceEnd: maintenanceEnd,
            ),
            200,
          );
        }

        if (path.contains(
            '/mobile-api/v2/registration/authenticate/off-platform')) {
          return Response(GingerHttpFixtures.credentialsResponse, 200);
        }
        if (path.contains('onboard_scheduler/available_times/')) {
          return Response(
            ListenerHttpFixtures.onboardSchedulerAvailableTimesResponse,
            200,
          );
        }
        if (path.contains('onboard_scheduler/headspace_member_token/')) {
          return Response(
            ListenerHttpFixtures.authTokenResponse,
            200,
          );
        }
        if (path.contains('/profile/v2/profiles')) {
          return Response(
            HeadspaceHttpFixtures.memberInfoResponse,
            200,
          );
        }
        if (path.contains('onboard_scheduler/headspace_available_times/')) {
          return Response(
            ListenerHttpFixtures.onboardSchedulerAvailableTimesResponse,
            200,
          );
        }
        if (path.contains('/user-details')) {
          return Response(GingerHttpFixtures.userResponse(), 200);
        }
        print('path: $path');

        return null;
      }),
    );
  }

  /// Inserts a priority matcher on top of [matchers]. With this, we can easily
  /// override responses in our tests.
  ///
  ///
  /// Tips: Inside test setups and tests, return null by default when inserting
  /// new matchers in order for next checks to be run through the check.
  @override
  void insert(ResponseMatcher matcher) {
    matchers.insert(0, matcher);
  }

  /// The way this works is that as soon as we found the very first match among
  /// the [matchers] we will immediately return the corresponding [Response].
  @override
  Future<Response> findResponseFromMatchers({
    @required String path,
    String method,
    Map<String, dynamic> params,
  }) async {
    for (var responder in matchers) {
      Response response = await responder(path, method, params);
      if (response != null) {
        responses.add(path);
        return response;
      }
    }

    throw Exception("No matcher found for $method $path, assign matcher using"
        " serviceLocator.get<HttpResponseHelper>().insert()");
  }
}
