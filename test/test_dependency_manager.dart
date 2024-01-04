import 'dart:async';

import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/models/tz_provider.dart';
import 'package:care_dart_sdk/services/config_provider.dart';
import 'package:care_dart_sdk/services/maintenance_service.dart';
import 'package:care_dart_sdk/services/maintenance_service_http.dart';
import 'package:care_dart_sdk/services/modal_service.dart';
import 'package:care_dart_sdk/services/network_service/ginger_http.dart';
import 'package:care_dart_sdk/services/network_service/ginger_service.dart';
import 'package:care_dart_sdk/services/network_service/http_response_matcher.dart';
import 'package:care_dart_sdk/services/screen_service.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/utilities/app_metadata_util.dart';
import 'package:care_dart_sdk/utilities/deeplink.dart';
import 'package:care_dart_sdk/utilities/device_info_provider.dart';
import 'package:care_dart_sdk/utilities/environment_config.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:care_dart_sdk/utilities/network.dart';
import 'package:care_dart_sdk/utilities/platform_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/dependency/dependency_manager.dart';
import 'package:mini_ginger_web/services/ginger_http.dart' as wsHttp;
import 'package:mini_ginger_web/services/ginger_service.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:mini_ginger_web/utilities/local_app_metadata_util.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher/url_launcher.dart';

import 'mocks.dart';
import 'stubs/test_http_response_matcher.dart';

import 'package:intl/date_symbol_data_local.dart';

class TestDependencyManager extends DependencyManager {
  final Locale locale;
  final bool isGoldenTest;

  TestDependencyManager({
    EnvironmentType environmentType = EnvironmentType.TEST,
    @required Uri launchUrl,
    this.locale = const Locale('en'),
    this.isGoldenTest = false,
  }) : super(environmentType, launchUrl: launchUrl) {
    /// Initializes test specific provisions
    provideHttpMatcher();

    addTearDown(() async {
      await dispose();
    });
  }

  @override
  Future<void> init() async {
    if (!isGoldenTest) {
      await initializeDateFormatting();
    }
    await R.load(locale);
    await super.init();
  }

  /// ********************************************************
  /// Test specific provisions
  void provideHttpMatcher() {
    serviceLocator.registerSingletonAsync<HttpResponseMatcher>(
      () async => TestHttpResponseMatcher(),
    );
  }

  @override
  void provideDeviceInfo() {
    serviceLocator.registerSingletonAsync<DeviceInfoProvider>(() async {
      return DeviceInfoProviderStub();
    });
  }

  @override
  void provideMetricsProvider() {
    serviceLocator.registerSingletonAsync<MetricsProvider>(
      () async {
        registerFallbackValue(Event("eventName"));
        return MetricsProviderMock();
      },
    );
  }

  @override
  void provideLocalGingerService() {
    serviceLocator.registerSingletonAsync<NetworkService>(
      () async {
        await serviceLocator.ensureReady<AppMetaData>();
        await serviceLocator.ensureReady<TZProvider>();
        await serviceLocator.ensureReady<HttpResponseMatcher>();

        LocalAppMetaData appMetaData =
            serviceLocator.get<AppMetaData>() as LocalAppMetaData;
        TZProvider tzProvider = serviceLocator.get<TZProvider>();

        HttpResponseMatcher matcher = serviceLocator.get<HttpResponseMatcher>();

        return NetworkService(
          gingerHttp: GingerHttpStub(
            matcher,
            appVersion: appMetaData.version,
            buildNumber: appMetaData.buildNumber,
          ),
          hsAuthHttp: wsHttp.HeadspaceHttpStub(
            matcher,
            appVersion: appMetaData.version,
            buildNumber: appMetaData.buildNumber,
          ),
          listenerHttp: wsHttp.ListenerHttpStub(
            matcher,
            appVersion: appMetaData.version,
            buildNumber: appMetaData.buildNumber,
          ),
          appVersion: appMetaData.version,
          buildNumber: appMetaData.buildNumber,
          deviceTimezone: tzProvider.deviceTimeZone,
        );
      },
    );
  }

  @override
  void provideServiceAPI() {
    serviceLocator.registerSingletonAsync<ServiceAPI>(() async {
      await serviceLocator.ensureReady<NetworkService>();
      await serviceLocator.ensureReady<GingerService>();
      await serviceLocator.ensureReady<ConfigProvider>();
      await serviceLocator.ensureReady<FlutterSecureStorage>();
      var localGingerService = serviceLocator.get<NetworkService>();
      var gingerService = serviceLocator.get<GingerService>();
      var configProvider = serviceLocator.get<ConfigProvider>();
      var secureStorage = serviceLocator.get<FlutterSecureStorage>();
      var api = LocalServiceAPI(
        isTest: true,
        allowIsolates: false,
        listenForEvents: true,
        config: configProvider,
        secureStorage: secureStorage,
        applicationVersion: 'test',
        localGingerService: localGingerService,
        gingerService: gingerService,
      );
      api.appRouter = RouterMock();
      return api;
    });
  }

  @override
  void provideDeviceLaunchUtil() {
    var deviceLaunchUtil = DeviceLaunchUtilMock();
    registerFallbackValue(LaunchMode.platformDefault);
    when(() => deviceLaunchUtil.canLaunch(any())).thenAnswer((_) async => true);
    serviceLocator.registerSingleton<DeviceLaunchUtil>(deviceLaunchUtil);
  }

  @override
  void provideAppMetaData() {
    serviceLocator.registerLazySingletonAsync<AppMetaData>(() async {
      return AppMetaDataMock();
    });
  }

  @override
  void provideFlutterSecureStorage() {
    serviceLocator.registerLazySingletonAsync<FlutterSecureStorage>(() async {
      var storage = FlutterSecureStorageMock();

      await initStorageValuesFromUrlParams(storage);

      return storage;
    });
  }

  @override
  void providePlatformUtil() {
    serviceLocator.registerSingletonAsync<PlatformUtil>(() async {
      return PlatformUtilStub();
    });
  }

  @override
  void provideMaintenanceService() {
    serviceLocator.registerLazySingleton<MaintenanceService>(
      () => MaintenanceService(
        maintenanceServiceHttp: MaintenanceServiceHttpStub(
          serviceLocator.get<HttpResponseMatcher>(),
        ),
      ),
    );
  }

  @override
  void provideGingerService() {
    serviceLocator.registerSingletonAsync<GingerService>(
      () async {
        await serviceLocator.ensureReady<AppMetaData>();
        await serviceLocator.ensureReady<HttpResponseMatcher>();

        LocalAppMetaData appMetaData =
            serviceLocator.get<AppMetaData>() as LocalAppMetaData;
        HttpResponseMatcher matcher = serviceLocator.get<HttpResponseMatcher>();

        return GingerService(
          gingerHttp: GingerHttpStub(
            matcher,
            appVersion: "5.0.0",
            buildNumber: "1",
          ),
          listenerHttp: ListenerHttpStub(
            matcher,
            appVersion: "5.0.0",
            buildNumber: "1",
          ),
          appVersion: appMetaData.version,
          buildNumber: appMetaData.buildNumber,
        );
      },
    );
  }

  @override
  void provideNetworkDetector() {
    serviceLocator.registerSingletonAsync<NetworkDetector>(() async {
      return NetworkDetectorMock();
    });
  }

  @override
  void provideDeeplinkService() {
    serviceLocator.registerLazySingleton<DeepLinkService>(
      () => DeepLinkServiceMock(),
    );
  }

  @override
  void provideScreenService() {
    serviceLocator.registerLazySingleton<ScreenService>(
      () => ScreenServiceStub(),
    );
  }

  @override
  void provideModalService() {
    serviceLocator.registerSingletonAsync<ModalService>(() async{
      registerFallbackValue(FakeModalWidget());
      return ModalServiceMock();
    });
  }
}
