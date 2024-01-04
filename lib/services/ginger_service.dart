import "dart:async";

import 'package:care_dart_sdk/models/credentials.dart';
import 'package:care_dart_sdk/services/network_service/ginger_http.dart';
import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logging/logging.dart';
import 'package:mini_ginger_web/models/network_responses.dart';

import 'ginger_http.dart' as wsHttp;

class NetworkService {
  final log = Logger("NetworkService");

  wsHttp.ListenerHttp _listenerHttp;

  @visibleForTesting
  wsHttp.ListenerHttp get listenerHttp => _listenerHttp;

  wsHttp.HeadspaceHttp _hsAuthHttp;

  @visibleForTesting
  wsHttp.HeadspaceHttp get hsAuthHttp => _hsAuthHttp;

  GingerHttp _gingerHttp;

  @visibleForTesting
  GingerHttp get gingerHttp => _gingerHttp;

  NetworkService(
      {wsHttp.ListenerHttp listenerHttp,
      wsHttp.HeadspaceHttp hsAuthHttp,
      GingerHttp gingerHttp,
      String appVersion,
      String deviceTimezone,
      String buildNumber}) {
    _listenerHttp = listenerHttp ??
        wsHttp.ListenerHttp(
            appVersion: appVersion,
            deviceTimezone: deviceTimezone,
            buildNumber: buildNumber);

    _hsAuthHttp = hsAuthHttp ??
        wsHttp.HeadspaceHttp(
            appVersion: appVersion,
            deviceTimezone: deviceTimezone,
            buildNumber: buildNumber);

    _gingerHttp = gingerHttp ??
        GingerHttp(appVersion: appVersion, buildNumber: buildNumber);
  }

  // ------------------------------------------------------------------------
  // Listener network requests.
  // ------------------------------------------------------------------------
  Future<OnboardSchedulerAvailabilityResponse>
      onboardSchedulerAvailableTimes() async {
    var path = "onboard_scheduler/headspace_available_times/";
    final response = await _listenerHttp.get(path);

    return OnboardSchedulerAvailabilityResponse.fromJSON(response);
  }

  Future<EmptyResponse> onboardSchedulerSelectTime(DateTime date) async {
    var path = "onboard_scheduler/headspace_schedule_times/";
    Map<String, dynamic> payload = {"available_time": date.toIso8601String()};
    var response = await _listenerHttp.post(path,
        data: payload, extraHeaders: {"Content-Type": "application/json"});
    return EmptyResponse.fromJSON(response);
  }

  Future<CoachingSessionsResponse> scheduledCoachingSessions() async {
    var path = "onboard_scheduler/headspace_schedule_times/";
    var response = await _listenerHttp.get(path);

    return CoachingSessionsResponse.fromJSON(response);
  }

  Future<MemberInfoResponse> memberInfo() async {
    var authToken = (await getAuthToken()).token;

    var decoded = JwtDecoder.decode(authToken);
    var userIdEntry =
        decoded.entries.singleWhereOrNull((i) => i.key.endsWith('hsId'));

    Map<String, String> header = {
      "Authorization": "Bearer $authToken",
    };

    var path = "/profile/v2/profiles/${userIdEntry.value}";
    var response = await _hsAuthHttp.get(path, extraHeaders: header);

    return MemberInfoResponse.fromJSON(response);
  }

  Future<AuthTokenResponse> getAuthToken() async {
    var path = "onboard_scheduler/headspace_member_token/";
    var response = await _listenerHttp.get(path);

    return AuthTokenResponse.fromJSON(response);
  }

  Future<GingerCredentialResponse> authenticate(String workflowHash) async {
    const path = "/mobile-api/v2/registration/authenticate/off-platform";
    Map<String, dynamic> payload = {"workflow_hash": workflowHash};
    try {
      var response = await _gingerHttp.post(path, data: payload);
      var credentialResponse = GingerCredentialResponse.fromJSON(response);
      _gingerHttp.gingerCredentials = GingerCredentials(
        credentialResponse.userId,
        credentialResponse.serverSecret,
      );
      return credentialResponse;
    } catch (e, stacktrace) {
      log.severe(e, stacktrace);
      return null;
    }
  }
}
