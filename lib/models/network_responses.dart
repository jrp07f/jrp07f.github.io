import 'dart:convert';

import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/utilities/deeplink.dart';
import 'package:care_dart_sdk/utilities/serialization.dart';
import 'package:http/http.dart' as http;
import 'package:mini_ginger_web/models/member_info.dart';

class MemberInfoResponse extends GingerResponse {
  final HSMemberInfo info;

  MemberInfoResponse({this.info});

  factory MemberInfoResponse.fromJSON(http.Response response) {
    var data = GingerResponse.decode<Map<String, dynamic>>(
        utf8.decode(response.bodyBytes));

    return MemberInfoResponse(
      info: HSMemberInfo.fromMap(data),
    );
  }
}

class AuthTokenResponse extends GingerResponse {
  final String token;

  AuthTokenResponse({this.token});

  factory AuthTokenResponse.fromJSON(http.Response response) {
    var data = GingerResponse.decode<Map<String, dynamic>>(
        utf8.decode(response.bodyBytes));

    var token = data['access_token'];
    return AuthTokenResponse(
      token: token,
    );
  }
}
