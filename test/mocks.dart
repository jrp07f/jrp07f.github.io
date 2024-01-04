import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/services/modal_service.dart';
import 'package:care_dart_sdk/services/screen_service.dart';
import 'package:care_dart_sdk/services/streams/service_events.dart';
import 'package:care_dart_sdk/ui/modals/modal_widget.dart';
import 'package:care_dart_sdk/ui/navigators/navigation_router.dart';
import 'package:care_dart_sdk/utilities/deeplink.dart';
import 'package:care_dart_sdk/utilities/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mini_ginger_web/services/ginger_service.dart';
import 'package:mini_ginger_web/utilities/local_app_metadata_util.dart';
import 'package:mini_ginger_web/utilities/web_launch_util.dart';
import 'package:mini_ginger_web/view_models/add_card_model.dart';
import 'package:mini_ginger_web/view_models/coaching_session_confirmation_model.dart';
import 'package:mini_ginger_web/view_models/dependents_success_model.dart';
import 'package:mini_ginger_web/view_models/fusion_guardian_intake_model.dart';
import 'package:mini_ginger_web/view_models/fusion_teen_clinical_escalation_model.dart';
import 'package:mini_ginger_web/view_models/payment_model.dart';
import 'package:mini_ginger_web/view_models/scheduler_model.dart';
import 'package:mocktail/mocktail.dart';

class CoachingSchedulerModelMock extends Mock implements SchedulerModel {}

class CoachingSessionConfirmationModelMock extends Mock
    implements CoachingSessionConfirmationModel {}

class FusionGuardianConsentModelMock extends Mock
    implements FusionGuardianConsentModel {}

class FusionTeenClinicalEscalationModelMock extends Mock
    implements FusionTeenClinicalEscalationModel {}

class DependentsSuccessModelMock extends Mock
    implements DependentsSuccessModel {}

class PaymentModelMock extends Mock implements PaymentModel {}

class AddCardModelMock extends Mock implements AddCardModel {}

class RouterMock extends Mock implements NavigationRouter {}

class DeviceLaunchUtilMock extends Mock implements WebLaunchUtilImpl {}

class GingerServiceMock extends Mock implements NetworkService {}

class MetricsProviderMock extends Mock implements MetricsProvider {}

class AppMetaDataMock extends Mock implements LocalAppMetaData {

  @override
  String get appName => 'Web Scheduler';

  @override
  String get packageName => 'my.app';

  @override
  String get version => '1.0.0';

  @override
  String get buildNumber => '1.0.0';

}

class FlutterSecureStorageMock extends Mock implements FlutterSecureStorage {
  Map<String, String> values = {};

  @override
  Future<void> write({
    String key,
    String value,
    IOSOptions iOptions,
    AndroidOptions aOptions,
    LinuxOptions lOptions,
    WebOptions webOptions,
    MacOsOptions mOptions,
    WindowsOptions wOptions,
  }) {
    values[key] = value;
  }

  @override
  Future<String> read({
    String key,
    IOSOptions iOptions,
    AndroidOptions aOptions,
    LinuxOptions lOptions,
    WebOptions webOptions,
    MacOsOptions mOptions,
    WindowsOptions wOptions,
  }) async {
    return values[key];
  }
}

class ModalServiceMock extends Mock implements ModalService {}

class NetworkDetectorMock extends Mock implements NetworkDetector {}

class DeepLinkServiceMock extends Mock implements DeepLinkService {

  DeepLinkServiceMock() {
    when(() => preOnboardEvents).thenAnswer((realInvocation) => ServiceEventStream());
    when(() => postOnboardEvents).thenAnswer((realInvocation) => ServiceEventStream());
  }

}

class ScreenServiceStub extends Mock implements ScreenService {
  bool _isWakeLockEnable = false;

  @override
  Future<void> enableWakeLock() async {
    _isWakeLockEnable = true;
  }

  @override
  Future<void> disableWakeLock() async {
    _isWakeLockEnable = false;
  }

  @override
  Future<bool> isWakeLockEnabled() async {
    return _isWakeLockEnable;
  }

  @override
  Future<void> toggleWakeLock({bool on}) async {
    _isWakeLockEnable = !_isWakeLockEnable;
  }
}

class FakeModalWidget extends Fake implements ModalWidget {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '';
  }
}