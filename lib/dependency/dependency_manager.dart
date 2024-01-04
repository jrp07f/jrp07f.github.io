import 'package:amplitude_flutter/amplitude.dart';
import 'package:care_dart_sdk/analytics/metrics.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/database/data_stores/activity_store.dart';
import 'package:care_dart_sdk/database/data_stores/content_event_store.dart';
import 'package:care_dart_sdk/database/data_stores/library_content_store.dart';
import 'package:care_dart_sdk/database/data_stores/library_tag_store.dart';
import 'package:care_dart_sdk/database/data_stores/staff_store.dart';
import 'package:care_dart_sdk/database/data_stores/user_preference_store.dart';
import 'package:care_dart_sdk/database/data_stores/user_store.dart';
import 'package:care_dart_sdk/database/ginger_db.dart';
import 'package:care_dart_sdk/database/ginger_db_memory.dart';
import 'package:care_dart_sdk/models/tz_provider.dart';
import 'package:care_dart_sdk/services/config_provider.dart';
import 'package:care_dart_sdk/services/content_service/content_service.dart';
import 'package:care_dart_sdk/services/content_service/content_sync_service.dart';
import 'package:care_dart_sdk/services/content_service/utils/content_input_prefill_handler.dart';
import 'package:care_dart_sdk/services/image_service.dart';
import 'package:care_dart_sdk/services/maintenance_service.dart';
import 'package:care_dart_sdk/services/modal_service.dart';
import 'package:care_dart_sdk/services/network_service/ginger_service.dart';
import 'package:care_dart_sdk/services/screen_service.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/common_widgets/screen_layout_containers.dart';
import 'package:care_dart_sdk/ui/shared/global_keys.dart';
import 'package:care_dart_sdk/utilities/app_metadata_util.dart';
import 'package:care_dart_sdk/utilities/deeplink.dart';
import 'package:care_dart_sdk/utilities/device_info_provider.dart';
import 'package:care_dart_sdk/utilities/environment_config.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:care_dart_sdk/utilities/network.dart';
import 'package:care_dart_sdk/utilities/platform_util.dart';
import 'package:care_dart_sdk/utilities/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:mini_ginger_web/analytics/amplitude_metrics_provider.dart';
import 'package:mini_ginger_web/analytics/metrics.dart';
import 'package:mini_ginger_web/commons/storage_keys.dart';
import 'package:mini_ginger_web/env/web_scheduler_environment_config.dart';
import 'package:mini_ginger_web/services/content_service_web.dart';
import 'package:mini_ginger_web/services/ginger_service.dart';
import 'package:mini_ginger_web/services/logger_service.dart';
import 'package:mini_ginger_web/services/platform/platform_service.dart';
import 'package:mini_ginger_web/services/platform/web_platform_service.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:mini_ginger_web/utilities/local_app_metadata_util.dart';
import 'package:mini_ginger_web/utilities/web_launch_util.dart';
import 'package:mini_ginger_web/utilities/web_safe_platform_util.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DependencyManager {
  final WebOptions wOptions = const WebOptions(
    dbName: "SchedulerWebStorage",
    publicKey: "schedulerWebStorage",
  );

  final EnvironmentType environmentType;
  final Uri launchUrl;
  String preferredLanguage;
  String companyName;
  String companyImageUrl;
  String workflowHash;
  String enrollmentFlow;
  String memberType;

  DependencyManager(this.environmentType, {this.launchUrl}) {
    serviceLocator.allowReassignment = true;
  }

  Future<void> init() async {
    parseUrlParams();
    providePlatformUtil();
    provideDeviceInfo();
    provideAppMetaData();
    provideEnvironmentConfig();
    providePlatformService();

    provideTZProvider();
    provideNetworkDetector();
    provideMetricsConfig();
    provideMetricsProvider();
    provideConfigProvider();

    provideFlutterSecureStorage();
    provideImageService();
    provideLocalGingerService();
    provideModalService();
    provideContentService();
    provideContentSyncService();
    provideGingerService();
    provideScreenService();

    provideUserStore();
    provideActivityStore();
    provideContentEventsStore();
    providePreferencesStore();
    provideContentLibraryStore();
    provideLibraryTagsStore();
    provideStaffStore();

    provideDatabase();
    provideServiceAPI();

    provideAppLogger();
    provideDeviceLaunchUtil();

    provideWorkflowHash();
    provideEnrollmentFlow();
    provideMemberType();

    provideMaintenanceService();
    provideScreenLayoutContainers();

    provideDeeplinkService();

    provideContentInputPrefillHandler();

    loggingSetup();
    await serviceLocator.allReady();
  }

  Future<void> dispose() async {
    await serviceLocator.reset(dispose: true);
  }

  Future<void> loggingSetup() async {
    await serviceLocator.ensureReady<AppLogger>();

    Logger.root.level =
        environmentType == EnvironmentType.NOISY ? Level.ALL : Level.INFO;

    Logger.root.onRecord.listen((LogRecord rec) {
      if (kDebugMode) {
        print('${rec.level.name}: ${rec.time}: ${rec.message}');
      }
      //call log entries API
      serviceLocator.get<AppLogger>().log(rec);
    });
  }

  void provideTZProvider() {
    serviceLocator.registerLazySingletonAsync<TZProvider>(() async {
      var platformService = serviceLocator.get<PlatformService>();
      var tz = await platformService.getDeviceTimezone();

      TZProvider instance = TZProvider();
      instance.deviceTimeZone = tz;
      return instance;
    });
  }

  void provideDeviceInfo() {
    serviceLocator.registerSingletonAsync<DeviceInfoProvider>(
      () async {
        final deviceInfoProvider = DeviceInfoProvider();
        await deviceInfoProvider.load();
        return deviceInfoProvider;
      },
      dependsOn: [PlatformUtil],
    );
  }

  void provideMetricsConfig() {
    serviceLocator.registerSingletonAsync<MetricsConfig>(
      () async {
        await serviceLocator.ensureReady<AppMetaData>();
        await serviceLocator.ensureReady<DeviceInfoProvider>();
        await serviceLocator.ensureReady<NetworkDetector>();
        return LocalMetricsConfig(
          deviceInfoProvider: serviceLocator.get<DeviceInfoProvider>(),
        );
      },
    );
  }

  void provideMetricsProvider() {
    serviceLocator.registerSingletonAsync<MetricsProvider>(() async {
      EnvironmentConfig environmentConfig =
          serviceLocator.get<EnvironmentConfig>();

      /// Multi metrics setup
      final metricsConfig = serviceLocator.get<MetricsConfig>();
      final MultiMetricsProvider multiMetricsProvider =
          MultiMetricsProvider(config: metricsConfig);

      /// Amplitude Setup
      Amplitude amplitude =
          Amplitude.getInstance(instanceName: 'GingerWebStandaloneAmplitude');
      await amplitude.init(environmentConfig.amplitudeKey);

      final AmplitudeMetricsProvider amplitudeAnalytic =
          AmplitudeMetricsProvider(
        amplitude,
        localMetricsConfig: metricsConfig as LocalMetricsConfig,
      );
      multiMetricsProvider.add(amplitudeAnalytic);

      return multiMetricsProvider;
    }, dependsOn: [
      EnvironmentConfig,
      MetricsConfig,
    ]);
  }

  void providePlatformService() {
    serviceLocator.registerLazySingleton<PlatformService>(() {
      var instance = WebPlatformService();
      return instance;
    });
  }

  void provideLocalGingerService() {
    serviceLocator.registerLazySingletonAsync<NetworkService>(
      () async {
        await serviceLocator.ensureReady<AppMetaData>();
        await serviceLocator.ensureReady<TZProvider>();

        LocalAppMetaData appMetaData =
            serviceLocator.get<AppMetaData>() as LocalAppMetaData;
        TZProvider tzProvider = serviceLocator.get<TZProvider>();

        return NetworkService(
          appVersion: appMetaData.version,
          buildNumber: appMetaData.buildNumber,
          deviceTimezone: tzProvider.deviceTimeZone,
        );
      },
    );
  }

  void provideServiceAPI() {
    serviceLocator.registerSingletonAsync<ServiceAPI>(
      () async {
        await serviceLocator.ensureReady<EnvironmentConfig>();
        await serviceLocator.ensureReady<AppMetaData>();
        await serviceLocator.ensureReady<MetricsProvider>();
        await serviceLocator.ensureReady<ConfigProvider>();
        await serviceLocator.ensureReady<NetworkService>();
        await serviceLocator.ensureReady<GingerService>();
        await serviceLocator.ensureReady<FlutterSecureStorage>();
        await serviceLocator.ensureReady<GingerDB>();
        await serviceLocator.ensureReady<ContentSyncService>();

        ConfigProvider configProvider = serviceLocator.get<ConfigProvider>();
        NetworkService localGingerService =
            serviceLocator.get<NetworkService>();
        var gingerService = serviceLocator.get<GingerService>();
        LocalAppMetaData appMetaData =
            serviceLocator.get<AppMetaData>() as LocalAppMetaData;

        FlutterSecureStorage secureStorage =
            serviceLocator.get<FlutterSecureStorage>();
        await setPreferredLocale();

        LocalServiceAPI api = LocalServiceAPI(
          localGingerService: localGingerService,
          config: configProvider,
          secureStorage: secureStorage,
          applicationVersion: appMetaData.version,
          companyName: await getCompanyName(),
          companyImageUrl: await getCompanyImageUrl(),
          preferredLangCode: preferredLanguage,
          enrollmentFlow: await getEnrollmentFlow(),
          memberType: await getMemberType(),
          gingerService: gingerService,
        );

        await api.setAppLanguage(languageCode: preferredLanguage);

        var contentSyncService = serviceLocator.get<ContentSyncService>();
        contentSyncService.api = api;
        return api;
      },
    );
  }

  void parseUrlParams() {
    preferredLanguage = launchUrl.queryParameters['language'];
    companyName = launchUrl.queryParameters['cname'] ?? '';
    companyImageUrl = launchUrl.queryParameters['logo'] ?? '';
    workflowHash = launchUrl.queryParameters['workflow_hash'] ?? '';
    memberType = launchUrl.queryParameters['member_type'] ?? '';
    enrollmentFlow = memberType == 'D2C'
        ? 'fusion'
        : launchUrl.queryParameters['enrollment_flow'];
  }

  Future<String> getCompanyImageUrl() async {
    if (StringUtils.isNotEmpty(companyImageUrl)) {
      return companyImageUrl;
    }

    var storage = serviceLocator.get<FlutterSecureStorage>();
    try {
      var companyImageUrl = await storage.read(
          key: StorageKeys.kCompanyImageUrl, webOptions: wOptions);
      return companyImageUrl ?? '';
    } catch (e) {
      return "";
    }
  }

  Future<String> getCompanyName() async {
    if (StringUtils.isNotEmpty(companyName)) {
      return companyName;
    }

    var storage = serviceLocator.get<FlutterSecureStorage>();
    try {
      var cName = await storage.read(
          key: StorageKeys.kCompanyName, webOptions: wOptions);
      return cName ?? '';
    } catch (e) {
      return "";
    }
  }

  Future<void> setPreferredLocale() async {
    if (StringUtils.isNotEmpty(preferredLanguage)) {
      return;
    }

    var storage = serviceLocator.get<FlutterSecureStorage>();
    try {
      var locale = await storage.read(
          key: StorageKeys.kPreferredLocale, webOptions: wOptions);
      preferredLanguage = locale ?? 'en';
    } catch (e) {
      preferredLanguage = 'en';
    }
  }

  Future<String> getWorkflowHash() async {
    if (StringUtils.isNotEmpty(workflowHash)) {
      return workflowHash;
    }

    await serviceLocator.ensureReady<FlutterSecureStorage>();
    var storage = serviceLocator.get<FlutterSecureStorage>();
    try {
      var workflowHash = await storage.read(
          key: StorageKeys.kWorkflowHash, webOptions: wOptions);
      return workflowHash ?? "";
    } catch (e) {
      return "";
    }
  }

  Future<String> getEnrollmentFlow() async {
    if (enrollmentFlow != null) {
      return enrollmentFlow;
    }

    await serviceLocator.ensureReady<FlutterSecureStorage>();
    var storage = serviceLocator.get<FlutterSecureStorage>();
    try {
      var enrollmentFlow = await storage.read(
          key: StorageKeys.kEnrollmentFlow, webOptions: wOptions);
      return enrollmentFlow ?? "unknown";
    } catch (e) {
      return "unknown";
    }
  }

  Future<String> getMemberType() async {
    if (StringUtils.isNotEmpty(memberType)) {
      return memberType;
    }

    await serviceLocator.ensureReady<FlutterSecureStorage>();
    var storage = serviceLocator.get<FlutterSecureStorage>();
    try {
      var memberType = await storage.read(
          key: StorageKeys.kMemberType, webOptions: wOptions);
      return memberType ?? "";
    } catch (e) {
      return "";
    }
  }

  void provideAppLogger() {
    serviceLocator.registerLazySingletonAsync<AppLogger>(() async {
      await serviceLocator.ensureReady<EnvironmentConfig>();
      await serviceLocator.ensureReady<ServiceAPI>();
      await serviceLocator.ensureReady<AppMetaData>();

      var api = serviceLocator.get<ServiceAPI>() as LocalServiceAPI;
      LocalAppMetaData appMetaData =
          serviceLocator.get<AppMetaData>() as LocalAppMetaData;

      GingerLogger gingerLogger = GingerLogger(
        serviceAPI: api,
        appMetaData: appMetaData,
      );

      return gingerLogger;
    });
  }

  /// See [ConfigProvider.defaultConfiguration].
  void provideConfigProvider() {
    serviceLocator.registerSingletonAsync<ConfigProvider>(
      () async {
        await serviceLocator.ensureReady<EnvironmentConfig>();

        EnvironmentConfig environmentConfig =
            serviceLocator.get<EnvironmentConfig>();

        // To prevent experiment contamination by debug and staging,
        // we only allow experiments in EXPERIMENT and PROD environments.
        final allowExperiments = {
          EnvironmentType.EXPERIMENT,
          EnvironmentType.PROD,
        }.contains(environmentConfig.type);

        final ConfigProvider config = LocalConfig();
        await config.setDefaults();

        return config;
      },
    );
  }

  void provideFlutterSecureStorage() {
    serviceLocator.registerLazySingletonAsync<FlutterSecureStorage>(() async {
      var storage = FlutterSecureStorage(webOptions: wOptions);

      await initStorageValuesFromUrlParams(storage);

      return storage;
    });
  }

  Future<void> initStorageValuesFromUrlParams(
      FlutterSecureStorage storage) async {
    if (StringUtils.isNotEmpty(companyName)) {
      await storage.write(key: StorageKeys.kCompanyName, value: companyName);

      // remove workflow hash if user deeplinks to web scheduler
      if (StringUtils.isEmpty(workflowHash)) {
        await storage.write(
          key: StorageKeys.kWorkflowHash,
          value: null,
        );
      }
    }

    if (StringUtils.isNotEmpty(companyImageUrl)) {
      await storage.write(
          key: StorageKeys.kCompanyImageUrl, value: companyImageUrl);
    }

    if (StringUtils.isNotEmpty(preferredLanguage)) {
      await storage.write(
        key: StorageKeys.kPreferredLocale,
        value: preferredLanguage,
      );
    }

    if (StringUtils.isNotEmpty(workflowHash)) {
      await storage.write(
        key: StorageKeys.kWorkflowHash,
        value: workflowHash,
      );
    }

    if (StringUtils.isNotEmpty(enrollmentFlow)) {
      await storage.write(
        key: StorageKeys.kEnrollmentFlow,
        value: enrollmentFlow,
      );
    }

    if (StringUtils.isNotEmpty(memberType)) {
      await storage.write(
        key: StorageKeys.kMemberType,
        value: memberType,
      );
    }
  }

  void provideEnvironmentConfig() {
    serviceLocator.registerSingletonAsync<EnvironmentConfig>(() async {
      var environmentConfig =
          await Environment.getEnvironmentConfig(environmentType);
      var webSchedulerEnvironmentConfig =
          await WebSchedulerEnvironment.getWebSchedulerEnvironmentConfig(
        environmentType,
        environmentConfig,
      );
      return webSchedulerEnvironmentConfig;
    });
  }

  void provideAppMetaData() {
    serviceLocator.registerLazySingletonAsync<AppMetaData>(() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return LocalAppMetaData(packageInfo: packageInfo);
    });
  }

  void provideDeviceLaunchUtil() {
    serviceLocator.registerSingleton<DeviceLaunchUtil>(WebLaunchUtilImpl());
  }

  void provideModalService() {
    serviceLocator.registerSingleton<ModalService>(
        ModalService(NavigatorKeys.rootNavigatorKey));
  }

  void provideWorkflowHash() {
    serviceLocator.registerFactoryAsync<String>(
      () async {
        return getWorkflowHash();
      },
      instanceName: 'workflowHash',
    );
  }

  void provideEnrollmentFlow() {
    serviceLocator.registerFactoryAsync<String>(
      () async {
        return getEnrollmentFlow();
      },
      instanceName: 'enrollmentFlow',
    );
  }

  void provideMemberType() {
    serviceLocator.registerFactoryAsync<String>(
          () async {
        return getMemberType();
      },
      instanceName: 'memberType',
    );
  }

  void providePlatformUtil() {
    serviceLocator.registerSingletonAsync<PlatformUtil>(() async {
      return WebSafePlatformUtil();
    });
  }

  void provideContentService() {
    serviceLocator.registerLazySingleton<ContentService>(() {
      return ContentServiceWeb();
    });
  }

  void provideContentSyncService() {
    serviceLocator.registerLazySingletonAsync<ContentSyncService>(() async {
      await serviceLocator.ensureReady<GingerDB>();

      GingerDB db = serviceLocator.get<GingerDB>();
      return ContentSyncService(db);
    });
  }

  void provideMaintenanceService() {
    serviceLocator.registerLazySingleton<MaintenanceService>(
      () => MaintenanceService(),
    );
  }

  void provideGingerService() {
    serviceLocator.registerSingletonAsync<GingerService>(
      () async {
        LocalAppMetaData appMetaData =
            serviceLocator.get<AppMetaData>() as LocalAppMetaData;

        return GingerService(
          appVersion: appMetaData.version,
          buildNumber: appMetaData.buildNumber,
        );
      },
      dependsOn: [AppMetaData],
    );
  }

  void provideScreenLayoutContainers() {
    serviceLocator.registerFactory<ScreenLayoutContainers>(() {
      return ScreenLayoutContainers();
    });
  }

  void provideDatabase() {
    serviceLocator.registerSingletonAsync<GingerDB>(() async {
      var gingerDB = GingerDBMemory();
      return gingerDB;
    });
  }

  void provideUserStore() {
    serviceLocator.registerLazySingleton<UserStore>(() => UserMemoryStore());
  }

  void provideActivityStore() {
    serviceLocator
        .registerLazySingleton<ActivityStore>(() => ActivityMemoryStore());
  }

  void provideContentEventsStore() {
    serviceLocator.registerLazySingleton<ContentEventStore>(
      () => ContentEventMemoryStore(),
    );
  }

  void providePreferencesStore() {
    serviceLocator.registerLazySingleton<UserPreferenceStore>(
      () => UserPreferenceMemoryStore(),
    );
  }

  void provideContentLibraryStore() {
    serviceLocator.registerLazySingleton<ContentLibraryStore>(
      () => ContentLibraryMemoryStore(),
    );
  }

  void provideLibraryTagsStore() {
    serviceLocator.registerLazySingleton<LibraryTagStore>(
      () => LibraryTagMemoryStore(),
    );
  }

  // void provideIntlPhoneUtil() {
  //   serviceLocator.registerSingletonAsync<GingerPhoneUtil>(GingerPhoneUtil());
  // }

  void provideNetworkDetector() {
    serviceLocator.registerSingletonAsync<NetworkDetector>(() async {
      return NetworkDetector();
    });
  }

  void provideImageService() {
    serviceLocator.registerFactory<ImageService>(() {
      return ImageService();
    });
  }

  void provideDeeplinkService() {
    serviceLocator.registerLazySingleton<DeepLinkService>(() {
      return DeepLinkService();
    });
  }

  void provideStaffStore() {
    serviceLocator.registerLazySingleton<StaffStore>(() => StaffMemoryStore());
  }

  void provideScreenService() {
    serviceLocator.registerSingleton<ScreenService>(ScreenService());
  }

  void provideContentInputPrefillHandler() {
    serviceLocator.registerSingletonAsync<ContentInputPrefillHandler>(() async {
      await serviceLocator.ensureReady<ServiceAPI>();
      return ContentInputPrefillHandler();
    });
  }
}
