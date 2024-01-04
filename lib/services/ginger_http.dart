import "dart:async";
import "dart:convert";
import 'dart:io' show IOException, SocketException;
import 'dart:math';

import 'package:care_dart_sdk/services/network_service/ginger_http.dart';
import 'package:care_dart_sdk/services/network_service/http_response_matcher.dart';
import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/utilities/device_info_provider.dart';
import 'package:care_dart_sdk/utilities/environment_config.dart';
import 'package:flutter/foundation.dart';
import "package:http/http.dart" as http;
import 'package:logging/logging.dart';
import 'package:mini_ginger_web/commons/serialization.dart';
import 'package:mini_ginger_web/env/web_scheduler_environment_config.dart';
import 'package:mini_ginger_web/services/http_clients/http_client_default.dart'
  if (dart.library.js) 'package:mini_ginger_web/services/http_clients/http_client_browser.dart';

const String jsonContentType = "application/json";
const String formContentType = "application/x-www-form-urlencoded";

final log = Logger("GingerBaseHttp");

// Base Service API.
abstract class GingerBaseHttp {
  final String appVersion;
  final String buildNumber;
  final String deviceTimezone;

  DateTime requestStart;

  DeviceInfoProvider get deviceInfoProvider => serviceLocator
      .get<DeviceInfoProvider>();

  GingerBaseHttp({this.appVersion, this.buildNumber, this.deviceTimezone});

  /// In case we need to add more web specific headers
  Map<String, String> get _webHeaders {
    Map<String, String> headers = commonHeaders;

    return headers;
  }

  Future<T> withClient<T>(Future<T> Function(http.Client) fn) async {
    var client = platformClient;
    try {
      return await fn(client);
    } finally {
      client.close();
    }
  }

  /// In case we need to add more mobile specific headers
  Map<String, String> get _mobileHeaders {
    Map<String, String> headers = commonHeaders;

    return headers;
  }

  Map<String, String> get commonHeaders {

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };
    return headers;
  }

  Map<String, String> get listenerHeaders {
    Random rnd = Random();

    Map<String, String> headers = {
      "Device-Timezone": deviceTimezone,
      "Device-Model": deviceInfoProvider.deviceModel,
      "Accept-Language": deviceInfoProvider.systemLanguages.join(', '),
      "Device-OS-Version": deviceInfoProvider.osVersion,
      "Device-OS": deviceInfoProvider.deviceOS,
      "Device-Application-Version": appVersion,
      "Device-Build-Number": buildNumber,
      "X-Request-ID": "${rnd.nextInt(4294967295).toString().padLeft(8, '0')}"
          "${rnd.nextInt(4294967295).toString().padLeft(8, '0')}"
    };

    headers.addAll(commonHeaders);
    return headers;
  }

  @visibleForTesting
  Map<String, String> get baseHeaders {
    if(kIsWeb) return _webHeaders;

    return _mobileHeaders;
  }

  void logRequest({String method, String url}) {
    requestStart = DateTime.now();
    log.info('API start [$method] $url');
  }

  void logResponse(http.Response response) {
    if (requestStart == null) {
      /// we are in test environment. exit
      return;
    }

    int duration = DateTime.now().difference(requestStart)
        .inMilliseconds;

    try {
      var data = GingerResponse.decode<Map<String, dynamic>>(response.body);
      dynamic detail = data["detail"] ?? data["error"];
      log.info("API end [${response.request.method.toUpperCase()}] "
          "${response.statusCode} ${response.request.url} "
          "duration: ${duration}ms success: ${data['success']} detail: $detail");
    } catch(e) {
      log.info("API end [${response.request.method.toUpperCase()}] "
          "${response.statusCode} ${response.request.url} "
          "duration: ${duration}ms success: false detail: ${e.toString()}");
    }
  }

  void throwOnFailureCode(http.Response response, [DateTime startTime]) {
    /// Log this response
    logResponse(response);

    if (response.statusCode == 403) {
      var result = jsonDecode(response.body);
      final detail = result["detail"];
      String detailString = PreserveNull.asString(detail) ?? "";
      if (detail != null &&
          (detailString.contains("b lank-server-secret") ||
              detailString.contains("u nauthorized") ||
              detailString.contains("u ser-does-not-exist"))) {
        throw GingerAuthError(detail);
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GingerStatusError(response);
    }
  }

  String _bookendSlash(String path) {
    if (path.substring(path.length - 1) != "/") {
      path = "$path/";
    }
    if (path.substring(0, 1) != "/") {
      path = "/$path";
    }
    return path;
  }
}

class HeadspaceHttp extends GingerBaseHttp {

  HeadspaceHttp({
    String appVersion,
    String buildNumber,
    String deviceTimezone
  }) : super(appVersion: appVersion,
      buildNumber: buildNumber, deviceTimezone: deviceTimezone);


  Future<http.Response> get(String path,
      {Map<String, String> params, Map<String, String> extraHeaders}) async {
    Map<String, String> queryParams = {};

    if (params != null) {
      queryParams.addAll(params);
    }

    Uri url = _hsAuthUrl(path, params: queryParams);
    var headers =  commonHeaders;
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    try {
      /// Log this request to LogEntries
      logRequest(url: url.toString(), method: 'GET');

      final response = await http.get(url,
          headers: headers);

      throwOnFailureCode(response);
      return response;
    } on http.ClientException catch (e) {
      throw SocketException("ClientException has occurred: $e");
    } on IOException catch (e) {
      throw SocketException("IOException has occurred: $e");
    }
  }

  Uri _hsAuthUrl(String path, {Map<String, String> params}) {
    params ??= {};
    return Uri(
      scheme: "https",
      host: WebSchedulerEnvironment.current.headspaceAuthHost,
      path: _bookendSlash(path),
      queryParameters: params,
    );
  }
}

/// Listener Service API.
class ListenerHttp extends GingerBaseHttp {

  ListenerHttp({
    String appVersion,
    String buildNumber,
    String deviceTimezone
  }) : super(appVersion: appVersion,
      buildNumber: buildNumber, deviceTimezone: deviceTimezone);

  Future<http.Response> post(String path,
      {Map<String, dynamic> data, Map<String, String> extraHeaders}) async {
    var listenerHeaders = _listenerHeaders();
    Uri listenerUri = _listenerUri(path);
    if (extraHeaders != null) listenerHeaders.addAll(extraHeaders);

    try {
      /// Log this request to LogEntries
      logRequest(url: listenerUri.toString(), method: 'POST');

      if (data == null) {
        final response = await withClient((client) =>
            client.post(listenerUri, headers: listenerHeaders));
        throwOnFailureCode(response);
        return response;
      }

      var payload = jsonEncode(data);
      final response = await withClient((client) => client.post(listenerUri,
          body: payload, headers: listenerHeaders));

      throwOnFailureCode(response);
      return response;
    } on http.ClientException catch (e) {
      throw SocketException("ClientException has occurred: $e");
    } on IOException catch (e) {
      throw SocketException("IOException has occurred: $e");
    }
  }

  Future<http.Response> get(String path,
      {Map<String, String> params, Map<String, String> extraHeaders}) async {
    Map<String, String> queryParams = {};

    if (params != null) {
      queryParams.addAll(params);
    }

    Uri listenerUri = _listenerUri(path, params: queryParams);
    var listenerHeaders = _listenerHeaders();
    if (extraHeaders != null) listenerHeaders.addAll(extraHeaders);
    try {
      /// Log this request to LogEntries
      logRequest(url: listenerUri.toString(), method: 'GET');

      final response = await withClient((client) => client.get(listenerUri,
          headers: listenerHeaders));
      throwOnFailureCode(response);
      return response;
    } on http.ClientException catch (e) {
      throw SocketException("ClientException has occurred: $e");
    } on IOException catch (e) {
      throw SocketException("IOException has occurred: $e");
    }
  }

  Future<http.Response> delete(String path,
      {Map<String, String> params, Map<String, String> extraHeaders}) async {
    var queryParams = {};

    if (params != null) {
      queryParams.addAll(params);
    }

    Uri listenerUri = _listenerUri(path, params: queryParams);
    var listenerHeaders = _listenerHeaders();
    if (extraHeaders != null) listenerHeaders.addAll(extraHeaders);
    try {
      /// Log this request to LogEntries
      logRequest(url: listenerUri.toString(), method: 'DELETE');
      final response = await withClient((client) => client.delete(
          listenerUri, headers: listenerHeaders));
      throwOnFailureCode(response);
      return response;
    } on http.ClientException catch (e) {
      throw SocketException("ClientException has occurred: $e");
    } on IOException catch (e) {
      throw SocketException("IOException has occurred: $e");
    }
  }

  Uri _listenerUri(String path, {Map<String, String> params}) {
    params ??= {};

    return Uri(
        scheme: "https",
        host: Environment.current.listenerHost,
        path: _bookendSlash(path),
        queryParameters: params,
    );
  }

  Map<String, String> _listenerHeaders() {
    Map<String, String> headers = listenerHeaders;
    return headers;
  }
}

/// Simple TestStub for GingerHttp.
class WebSchedulerGingerHttpStub extends GingerHttp {
  HttpResponseMatcher matcher;

  WebSchedulerGingerHttpStub(this.matcher, {String appVersion, String buildNumber})
      : super(appVersion: appVersion, buildNumber: buildNumber);

  @override
  Future<http.Response> post(String path,
      {Map<String, dynamic> data, Map<String, String> extraHeaders}) async {
    http.Response response = await matcher.findResponseFromMatchers(
      path: path,
      method: "POST",
      params: data,
    );
    throwOnFailureCode(response);
    return Future.value(response);
  }

  @override
  Future<http.Response> get(String path,
      {Map<String, String> params, Map<String, String> extraHeaders}) async {
    http.Response response = await matcher.findResponseFromMatchers(
      path: path,
      method: "GET",
      params: params,
    );
    throwOnFailureCode(response);
    return Future.value(response);
  }

  @override
  Future<http.Response> delete(String path,
      {Map<String, String> params, Map<String, String> extraHeaders}) async {
    http.Response response = await matcher.findResponseFromMatchers(
      path: path,
      method: "DELETE",
      params: params,
    );
    throwOnFailureCode(response);
    return Future.value(response);
  }
}

/// Simple TestStub for ListenerHttp.
class ListenerHttpStub extends ListenerHttp {
  HttpResponseMatcher matcher;

  ListenerHttpStub(this.matcher, {String appVersion, String buildNumber})
      : super(appVersion: appVersion, buildNumber: buildNumber);

  @override
  Future<http.Response> post(String path,
      {Map<String, dynamic> data, Map<String, String> extraHeaders}) async {
    http.Response response = await matcher.findResponseFromMatchers(
      path: path,
      method: "POST",
      params: data,
    );
    throwOnFailureCode(response);
    return Future.value(response);
  }

  @override
  Future<http.Response> get(String path,
      {Map<String, String> params, Map<String, String> extraHeaders}) async {
    http.Response response = await matcher.findResponseFromMatchers(
      path: path,
      method: "GET",
      params: params,
    );
    throwOnFailureCode(response);
    return Future.value(response);
  }

  @override
  Future<http.Response> delete(String path,
      {Map<String, String> params, Map<String, String> extraHeaders}) async {
    http.Response response = await matcher.findResponseFromMatchers(
      path: path,
      method: "DELETE",
      params: params,
    );
    throwOnFailureCode(response);
    return Future.value(response);
  }
}

/// Simple TestStub for HeadspaceHttpStub.
class HeadspaceHttpStub extends HeadspaceHttp {
  HttpResponseMatcher matcher;

  HeadspaceHttpStub(this.matcher, {String appVersion, String buildNumber})
      : super(appVersion: appVersion, buildNumber: buildNumber);

  @override
  Future<http.Response> post(String path,
      {Map<String, dynamic> data, Map<String, String> extraHeaders}) async {
    http.Response response = await matcher.findResponseFromMatchers(
      path: path,
      method: "POST",
      params: data,
    );
    throwOnFailureCode(response);
    return Future.value(response);
  }

  @override
  Future<http.Response> get(String path,
      {Map<String, String> params, Map<String, String> extraHeaders}) async {
    http.Response response = await matcher.findResponseFromMatchers(
      path: path,
      method: "GET",
      params: params,
    );
    throwOnFailureCode(response);
    return Future.value(response);
  }

  @override
  Future<http.Response> delete(String path,
      {Map<String, String> params, Map<String, String> extraHeaders}) async {
    http.Response response = await matcher.findResponseFromMatchers(
      path: path,
      method: "DELETE",
      params: params,
    );
    throwOnFailureCode(response);
    return Future.value(response);
  }
}
