import 'dart:convert';

import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/utilities/environment_config.dart';
import 'package:care_dart_sdk/utilities/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Responsible for managing environment settings of an app setup.
/// This is usually used in the project's main(). Please see main.dart
class WebSchedulerEnvironment {
  /// The content version reference. This should only be the place it can
  /// be changed

  static WebSchedulerEnvironmentConfig get current =>
      serviceLocator.get<EnvironmentConfig>() as WebSchedulerEnvironmentConfig;

  /// The initial method called for initializing the config's values. If
  /// [shouldAppendFileValues] is true, it will try to append values from the config
  /// files.
  static Future<void> setEnvironment(
    EnvironmentType environmentType,
    EnvironmentConfig environmentConfig, {
    bool shouldAppendFileValues = true,
  }) async {
    EnvironmentConfig config = await getWebSchedulerEnvironmentConfig(
      environmentType,
      environmentConfig,
      shouldAppendFileValues: shouldAppendFileValues,
    );

    serviceLocator.registerSingleton<EnvironmentConfig>(config);
  }

  static Future<WebSchedulerEnvironmentConfig> getWebSchedulerEnvironmentConfig(
    EnvironmentType environmentType,
    EnvironmentConfig environmentConfig, {
    bool shouldAppendFileValues = true,
  }) async {
    WebSchedulerEnvironmentConfig config = WebSchedulerEnvironmentConfig(
      headspaceAuthHost: "api.staging.headspace.com",
      type: environmentConfig.type,
      gingerHost: environmentConfig.gingerHost,
      listenerHost: environmentConfig.listenerHost,
      amplitudeKey: environmentConfig.amplitudeKey,
      loggerHost: environmentConfig.loggerHost,
      loggerKey: environmentConfig.loggerKey,
      stripeKey: environmentConfig.stripeKey,
      mode: environmentConfig.mode,
      bundledContentVersion: environmentConfig.bundledContentVersion,
      gingerBaseUrl: environmentConfig.gingerBaseUrl,
      listenerBaseUrl: environmentConfig.listenerBaseUrl,
    );

    switch (environmentType) {
      case EnvironmentType.EXPERIMENT:
      case EnvironmentType.NOISY:
      case EnvironmentType.STAGING:
      case EnvironmentType.WEB_STAGING:
        if (shouldAppendFileValues) {
          if (environmentType == EnvironmentType.WEB_STAGING) {
            await config.appendWebSchedulerValuesFromFile(
                "assets/cfg/web_staging_env_variables.json");
          } else {
            await config.appendWebSchedulerValuesFromFile(
                "assets/cfg/staging_env_variables.json");
          }
        }
        break;
      case EnvironmentType.PROD:
      case EnvironmentType.DEBUGGABLE_PROD:
      case EnvironmentType.WEB_PROD:
        if (shouldAppendFileValues) {
          if (environmentType == EnvironmentType.WEB_PROD) {
            await config.appendWebSchedulerValuesFromFile(
                "assets/cfg/web_prod_env_variables.json");
          } else {
            await config.appendWebSchedulerValuesFromFile(
                "assets/cfg/prod_env_variables.json");
          }
        }
        break;
      case EnvironmentType.DEBUG:
      case EnvironmentType.TEST:
      case EnvironmentType.AUTOMATION:
      default:
        break;
    }
    return config;
  }
}

/// Contains configurable variables that will be used across the app.
class WebSchedulerEnvironmentConfig extends EnvironmentConfig {
  String headspaceAuthHost;

  WebSchedulerEnvironmentConfig({
    @required this.headspaceAuthHost,
    EnvironmentType type,
    String gingerHost,
    String listenerHost,
    String amplitudeKey,
    String loggerHost,
    String loggerKey,
    String stripeKey,
    RuntimeMode mode,
    int bundledContentVersion,
    String gingerBaseUrl,
    String listenerBaseUrl,
  }) : super(
          type: type,
          gingerHost: gingerHost,
          listenerHost: listenerHost,
          amplitudeKey: amplitudeKey,
          loggerHost: loggerHost,
          loggerKey: loggerKey,
          stripeKey: stripeKey,
          mode: mode,
          bundledContentVersion: bundledContentVersion,
          gingerBaseUrl: gingerBaseUrl,
          listenerBaseUrl: listenerBaseUrl,
        );

  /// Appends values from config files content
  Future<void> appendWebSchedulerValuesFromFile(String path) async {
    try {
      String content = await rootBundle.loadString(path);

      if (StringUtils.isEmpty(content)) {
        throw ConfigNotFoundError(message: '$path content is empty');
      }

      appendWebSchedulerMapValues(jsonDecode(content));
    } catch (e) {
      throw ConfigNotFoundError(
          message: '$path file is missing,'
              ' get file from env key and add to assets/cfg folder.',
          error: e);
    }
  }

  void appendWebSchedulerMapValues(Map<String, dynamic> map) {
    gingerHost = map['ginger_host'];
    listenerHost = map['listener_host'];
    headspaceAuthHost = map['headspace_auth_host'];
    loggerHost = map['logger_host'];
    amplitudeKey = map['amplitude_key'];
    loggerKey = map['logger_key'];
    stripeKey = map['stripe_key'];
  }
}
