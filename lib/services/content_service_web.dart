import 'dart:async';
import 'dart:io';

import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/services/content_service/content_service.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/utilities/environment_config.dart';
import 'package:logging/logging.dart';

/// The content service manages the content metadata for web.
class ContentServiceWeb extends ContentService {
  @override
  Logger log = Logger('ContentServiceWeb');

  ContentServiceWeb();

  @override
  Future<void> initActivitiesMetadataRoot() async {
    try {
      // Initialize activities metadata root.
      log.info("Initializing activities metadata root from asset bundle.");
      var jsonString = await metadataFileUtil.copyFromBundleAsString(
          "packages/care_dart_sdk/assets/activities_metadata_root.json");
      jsonString = updateUrlsBasedOnEnvironmentType(jsonString);
      await resetContentMetadataInMemory(jsonString);

      log.info("Activities metadata initialization completed successfully");
    } catch (e, stacktrace) {
      log.severe('Activities metadata initialization failed : ${e.toString()}',
          e, stacktrace);
      log.info(stacktrace);

      serviceLocator
          .get<MetricsProvider>()
          .track(UnableToInitializeActivitiesMetadataEvent(
        userId: serviceAPI.userId,
        message: e.toString(),
      ));
    }
  }

  String updateUrlsBasedOnEnvironmentType(String jsonString) {
    var originalUrl = 'https://content-repository.ginger.io';
    var updatedUrl = 'https://content-repository.ginger.dev';
    var environmentConfig = serviceLocator.get<EnvironmentConfig>();
    if(environmentConfig.type.isProd) {
      originalUrl = 'https://content-repository.ginger.dev';
      updatedUrl = 'https://content-repository.ginger.io';
    }
    return jsonString.replaceAll(originalUrl, updatedUrl);
  }
}