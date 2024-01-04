import 'dart:async';
import "dart:convert";

import 'package:care_dart_sdk/utilities/environment_config.dart';
import 'package:flutter/foundation.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import "package:http/http.dart" as http;
import 'package:logging/logging.dart';
import 'package:mini_ginger_web/utilities/local_app_metadata_util.dart';

abstract class AppLogger {
  FutureOr<bool> log(LogRecord logRecord);
}

///Class for pushing log messages to the log entries API
class GingerLogger implements AppLogger {
  final LocalAppMetaData appMetaData;
  final LocalServiceAPI serviceAPI;

  GingerLogger({@required this.serviceAPI, @required this.appMetaData});

  @override
  FutureOr<bool> log(LogRecord logRecord) async {
    if (Environment.current.type == EnvironmentType.DEBUG ||
        Environment.current.type == EnvironmentType.AUTOMATION) return false;

    // Determine current environment mode
    var isDebugMode = true;
    if (Environment.current.type == EnvironmentType.PROD ||
        Environment.current.type == EnvironmentType.WEB_PROD ||
        Environment.current.type == EnvironmentType.EXPERIMENT) {
      isDebugMode = false;
    }

    var data = {
      "debug": isDebugMode,
      "userId": serviceAPI.hsUserId ?? 'ws_hs_user',
      "level": logRecord.level.name,
      "tag": logRecord.loggerName,
      "version": appMetaData.version,
      "build": appMetaData.buildNumber,
      "msg": logRecord.message,
      "stackTrace": logRecord.stackTrace?.toString(),
      "error": logRecord.error?.toString(),
    };
    var requestBody = jsonEncode(data);

    String apiKey = Environment.current.loggerKey;

    var response = await http.post(_logEntriesUri('noformat/logs/$apiKey'),
        body: requestBody, headers: _logEntriesHeaders());

    return response.statusCode == 204 ? true : false;
  }

  static Uri _logEntriesUri(String path, {Map<String, String> params}) {
    return Uri(
        scheme: "https",
        host: Environment.current.loggerHost,
        path: path,
        queryParameters: params);
  }

  static Map<String, String> _logEntriesHeaders() {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    return headers;
  }
}
