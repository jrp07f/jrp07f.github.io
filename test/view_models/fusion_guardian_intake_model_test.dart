import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/modals/modal_alert_dialog.dart';
import 'package:care_dart_sdk/utilities/deeplink.dart';
import 'package:care_dart_sdk/utilities/enums/timeline_chart_item_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/view_models/fusion_guardian_intake_model.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';
import '../test_dependency_manager.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FakeModalWidget());
  });

  setUp(() async {
    var launchUrl = Uri.parse(
        'http://localhost:63634/guardian-consent?workflow_hash=12314');
    var dependencyManager = TestDependencyManager(launchUrl: launchUrl);
    await dependencyManager.init();
  });

  group('handle(workflow) tests', () {
    test('handle consent status', () async {
      // GIVEN model
      var model = FusionGuardianConsentModel();
      var workflow = FusionWorkflow(
        id: 123,
        version: 456,
        status: FusionGuardianIntakeConsentStatus(
          deeplink: DeepLink(Uri.parse('gingerio://content?assignment=1212')),
          dependentId: 789,
        ),
      );

      // WHEN handle(workflow) is called
      model.handle(workflow);

      // THEN firstItem
      expect(model.firstItem.title, R.current.guardian_consent_team_consent_workflow_title);
      expect(model.firstItem.subtitle, R.current.guardian_consent_team_consent_workflow_subtitle);
      expect(model.firstItem.state, TimelineChartItemState.inProgress);
      expect(model.firstItem.onTap, isNotNull);

      // And secondItem
      expect(model.secondItem.title, R.current.guardian_consent_team_dependent_info_workflow_title);
      expect(model.secondItem.subtitle, R.current.guardian_consent_team_dependent_info_workflow_subtitle);
      expect(model.secondItem.state, TimelineChartItemState.notStarted);
      expect(model.secondItem.onTap, isNull);
    });

    test('handle declined status', () async {
      // GIVEN model
      var model = FusionGuardianConsentModel();
      var workflow = FusionWorkflow(
        id: 123,
        version: 456,
        status: FusionGuardianIntakeDeclinedStatus(
        ),
      );

      // WHEN handle(workflow) is called
      model.handle(workflow);

      // THEN firstItem
      expect(model.firstItem.title, R.current.guardian_consent_team_consent_workflow_title_rejected);
      expect(model.firstItem.subtitle, R.current.guardian_consent_team_consent_workflow_subtitle_rejected);
      expect(model.firstItem.state, TimelineChartItemState.declined);
      expect(model.firstItem.onTap, isNotNull);

      // And secondItem
      expect(model.secondItem.title, R.current.guardian_consent_team_dependent_info_workflow_title);
      expect(model.secondItem.subtitle, R.current.guardian_consent_team_dependent_info_workflow_subtitle);
      expect(model.secondItem.state, TimelineChartItemState.notStarted);
      expect(model.secondItem.onTap, isNull);
    });

    test('handle dependent_info status', () async {
      // GIVEN model
      var model = FusionGuardianConsentModel();
      var workflow = FusionWorkflow(
        id: 123,
        version: 456,
        status: FusionGuardianIntakeDependentInfoStatus(
          deeplink: DeepLink(Uri.parse('gingerio://content?assignment=1212')),
          dependentId: 789,
        ),
      );

      // WHEN handle(workflow) is called
      model.handle(workflow);

      // THEN firstItem
      expect(model.firstItem.title, R.current.guardian_consent_team_consent_workflow_title);
      expect(model.firstItem.subtitle, R.current.guardian_consent_team_consent_workflow_subtitle);
      expect(model.firstItem.state, TimelineChartItemState.completed);
      expect(model.firstItem.onTap, isNull);

      // And secondItem
      expect(model.secondItem.title, R.current.guardian_consent_team_dependent_info_workflow_title);
      expect(model.secondItem.subtitle, R.current.guardian_consent_team_dependent_info_workflow_subtitle);
      expect(model.secondItem.state, TimelineChartItemState.inProgress);
      expect(model.secondItem.onTap, isNotNull);
    });

    test('handle completed status', () async {
      // GIVEN model
      var model = FusionGuardianConsentModel();
      var workflow = FusionWorkflow(
        id: 123,
        version: 456,
        status: FusionGuardianIntakeCompletedStatus(),
      );

      // WHEN handle(workflow) is called
      model.handle(workflow);

      // THEN firstItem
      expect(model.firstItem.title, R.current.guardian_consent_team_consent_workflow_title);
      expect(model.firstItem.subtitle, R.current.guardian_consent_team_consent_workflow_subtitle);
      expect(model.firstItem.state, TimelineChartItemState.completed);
      expect(model.firstItem.onTap, isNull);

      // And secondItem
      expect(model.secondItem.title, R.current.guardian_consent_team_dependent_info_workflow_title);
      expect(model.secondItem.subtitle, R.current.guardian_consent_team_dependent_info_workflow_subtitle);
      expect(model.secondItem.state, TimelineChartItemState.completed);
      expect(model.secondItem.onTap, isNull);
    });
  });

  group('showErrorDialog tests', () {
    test('should call modalService', () async {
      // GIVEN model
      var model = FusionGuardianConsentModel();
      var api = serviceLocator.get<ServiceAPI>();

      // WHEN showErrorDialog() is called
      model.showErrorDialog('foo');

      // THEN modalService should be called
      verify(() => api.modalService.showImmediately(
        any(that: isInstanceOf<HSCustomAlertModal>()),
      )).called(1);
    });
  });
}
