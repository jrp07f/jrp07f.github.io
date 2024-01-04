import 'dart:async';

import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/utilities/environment_config.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mini_ginger_web/app.dart';
import 'package:mini_ginger_web/dependency/dependency_manager.dart';
import 'package:mini_ginger_web/services/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(() async {
    EnvironmentType environmentType = EnvironmentConfig.fromDartEnvironment();

    var dependencyManager = DependencyManager(
      environmentType,
      launchUrl: Uri.base,
    );

    runApp(MainApp(dependencyManager));
  }, (error, stack) async {
    var logRecord = LogRecord(
      Level.SEVERE,
      "Unhandled Dart Exception",
      "FlutterLogEntry",
      error,
      stack,
    );
    await serviceLocator.ensureReady<AppLogger>();
    await serviceLocator.get<AppLogger>().log(logRecord);
  });
}
