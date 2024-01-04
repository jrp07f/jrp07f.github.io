import 'dart:convert';

import 'package:care_dart_sdk/analytics/metrics.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/models/user.dart';
import 'package:care_dart_sdk/services/config_provider.dart';
import 'package:care_dart_sdk/services/network_service/ginger_service.dart';
import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/services/streams/service_events.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mini_ginger_web/analytics/metrics.dart';
import 'package:mini_ginger_web/commons/storage_keys.dart';
import 'package:mini_ginger_web/models/member_info.dart';
import 'package:mini_ginger_web/models/network_responses.dart';
import 'package:mini_ginger_web/navigation/app_routes.dart';
import 'package:mini_ginger_web/navigation/keys.dart';
import 'package:mini_ginger_web/services/ginger_service.dart';

class LocalServiceAPI extends ServiceAPI {
  final log = Logger("ServiceAPI");

  String hsUserId;

  @visibleForTesting
  NetworkService localGingerService;

  String companyImageUrl = '';
  String companyName = '';
  String preferredLangCode;
  String enrollmentFlow;
  String memberType;

  LocalServiceAPI({
    bool isTest = false,
    bool allowIsolates = true,
    bool listenForEvents = true,
    this.localGingerService,
    ConfigProvider config,
    FlutterSecureStorage secureStorage,
    String applicationVersion,
    this.companyImageUrl,
    this.companyName,
    this.preferredLangCode,
    this.enrollmentFlow,
    this.memberType,
    GingerService gingerService,
  }) : super(
          isTest: isTest,
          enableChat: false,
          enableExperiments: false,
          allowIsolates: allowIsolates,
          listenForEvents: listenForEvents,
          config: config,
          secureStorage: secureStorage,
          applicationVersion: applicationVersion,
          gingerService: gingerService,
        );

  /// Get initial coaching session availabilities.
  @override
  Future<OnboardSchedulerAvailabilityResponse>
      onboardSchedulerAvailableTimes() async {
    return localGingerService.onboardSchedulerAvailableTimes();
  }

  /// Set initial coaching session availabilities.
  @override
  Future<EmptyResponse> onboardSchedulerSelectTime(DateTime date) async {
    return localGingerService.onboardSchedulerSelectTime(date);
  }

  /// Retrieve onboarding scheduled coaching session
  @override
  Future<DateTime> onboardSchedulerSelectedTime() async {
    CoachingSessionsResponse response =
        await localGingerService.scheduledCoachingSessions();

    return response.onboardingSession?.toLocal();
  }

  Future<HSMemberInfo> fetchMemberInfo({bool fetchRemote = true}) async {
    var local = await loadMemberInfo();
    if (local != null && !fetchRemote) {
      hsUserId = local.userId;
      return local;
    }

    MemberInfoResponse response = await localGingerService.memberInfo();
    HSMemberInfo info = response?.info;
    hsUserId = info?.userId;

    metricsIdentifyHsMember(member: info);
    await recordCredentials(info);
    return info;
  }

  Future<void> recordCredentials(HSMemberInfo info) async {
    try {
      await secureStorage.write(key: StorageKeys.kHsUserInfo, value: info.raw);
    } catch (e, stack) {
      log.severe('Error while recording hs user credentials: ${e.toString()}',
          e, stack);
      rethrow;
    }
  }

  @visibleForTesting
  Future<HSMemberInfo> loadMemberInfo() async {
    try {
      var data = await secureStorage.read(key: StorageKeys.kHsUserInfo);
      Map decoded = jsonDecode(data);
      var info = HSMemberInfo.fromMap(decoded);
      return info;
    } catch (e, stack) {
      log.info('Hs user credentials not locally available: ${e.toString()}', e,
          stack);
      return null;
    }
  }

  /// This method is for triggering the process for updating the local in-app
  /// texts and date formats based on the user's preferred language from a
  /// single point. It also sends an `appLanguageChanged` ServiceEvent to
  /// listeners, if successful.
  ///
  /// [languageCode] - e.g. en, es, etc.
  @override
  Future<void> setAppLanguage(
      {@required String languageCode, bool appLaunching = false}) async {
    // Load the localized strings for the specified language.
    var locale = Locale(languageCode);
    await R.delegate.load(locale);

    // Set Jiffy package's default locale based on the current user's set
    // preferred language.
    await Jiffy.locale(languageCode);

    // Firebase config language change
    await serviceLocator
        .get<MetricsProvider>()
        .setUserProperties({'language': languageCode});

    log.info('App language set to {$languageCode}');
  }

  Future<void> metricsIdentifyHsMember({@required HSMemberInfo member}) async {
    LocalMetricsConfig config = LocalMetricsConfig(
        metricsUserId: member.userId,
        memberOrgName: companyName,
        preferredLanguage: preferredLangCode);

    var metricsProvider = serviceLocator.get<MetricsProvider>();
    metricsProvider?.setConfig(config);
    var metricsConfig = serviceLocator.get<MetricsConfig>() as LocalMetricsConfig;
    metricsConfig.metricsUserId = member.userId;
    metricsConfig.memberOrgName = companyName;
    metricsConfig.preferredLanguage = preferredLangCode;
    metricsProvider?.identify(member.userId);
  }

  /// Reload feature flags and configuration from the A/B provider.
  @override
  Future<void> reloadExperiments() async {
    await config.fetch();
  }

  Future<User> authenticate(
    String workflowHash,
  ) async {
    var gingerCredentialResponse =
        await localGingerService.authenticate(workflowHash);
    await setupUserFromCredentialsResponse(gingerCredentialResponse);
    return await authenticatedUser();
  }

  @override
  void exitInternalContentView() {
    /// If the Guardian consent screen is present we only want to pop until
    /// the Guardian consent form is completed instead of popping until
    /// teen clinical escalation.
    if ((Keys.guardianConsentScreenKey?.currentState?.mounted ??
        false)) {
      appRouter.popUntil(AppRoutes.guardianConsent);
    } else {
      appRouter.popUntil(AppRoutes.teenClinicalEscalation);
    }

    mayBeDisableWakeLock(currentlyPresentingActivity);

    serviceEvents.add(ServiceEvent(
      name: ServiceEvent.closedWebContent,
      payload: currentlyPresentingActivity?.assignmentId,
    ));

    currentlyPresentingActivity = null;
  }
}
