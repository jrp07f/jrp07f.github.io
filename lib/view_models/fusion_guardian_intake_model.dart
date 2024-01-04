import 'dart:async';

import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/models/content_event.dart';
import 'package:care_dart_sdk/models/timeline_chart_item.dart';
import 'package:care_dart_sdk/models/workflow.dart';
import 'package:care_dart_sdk/services/modal_service.dart';
import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/services/streams/service_events.dart';
import 'package:care_dart_sdk/ui/modals/modal_alert_dialog.dart';
import 'package:care_dart_sdk/ui/shared/ginger_alert_dialog.dart';
import 'package:care_dart_sdk/utilities/deeplink.dart';
import 'package:care_dart_sdk/utilities/enums/timeline_chart_item_state.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:mini_ginger_web/utilities/web_launch_util.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:logging/logging.dart';

class FusionGuardianConsentModel extends NavigationModel {
  final log = Logger('FusionGuardianIntakeModel');
  final api = serviceLocator.get<ServiceAPI>() as LocalServiceAPI;
  final metrics = serviceLocator.get<MetricsProvider>();

  StreamSubscription<ServiceEvent> serviceEventSubscription;

  TimelineChartItem firstItem;
  TimelineChartItem secondItem;

  Future<void> listenToServiceEvents() async {
    serviceEventSubscription = api.serviceEvents.listen(onServiceEvent);
  }

  Future<void> loadFusionGuardianIntakeWorkflow(String workflowHash) async {
    try {
      busy = true;
      notifyListeners();

      var workflow = await api.fetchFusionWorkflow(workflowHash);
      handle(workflow);
    } on GingerStatusError catch (e, stacktrace) {
      log.severe(e, stacktrace);
      showErrorDialog(e.message);
    } on GingerDetailedError catch (e, stacktrace) {
      log.severe(e, stacktrace);
      showErrorDialog(e.message);
    } catch (e, stacktrace) {
      log.severe(e, stacktrace);
      showErrorDialog(e.toString());
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @visibleForTesting
  void handle(FusionWorkflow workflow) {
    var workflowStatus = workflow.status;

    if (workflowStatus is FusionGuardianIntakeConsentStatus) {
      firstItem = TimelineChartItem(
        title: R.current.guardian_consent_team_consent_workflow_title,
        subtitle: R.current.guardian_consent_team_consent_workflow_subtitle,
        state: TimelineChartItemState.inProgress,
        onTap: () {
          metrics.track(GuardianConsentProvideConsentToServicesTapped());
          var deeplink = workflowStatus.deeplink;
          queueDeeplink(deeplink);
        },
      );
      secondItem = TimelineChartItem(
        title: R.current.guardian_consent_team_dependent_info_workflow_title,
        subtitle:
            R.current.guardian_consent_team_dependent_info_workflow_subtitle,
        state: TimelineChartItemState.notStarted,
        onTap: null,
      );

      var deeplink = workflowStatus.deeplink;
      queueDeeplink(deeplink);
    } else if (workflowStatus is FusionGuardianIntakeDeclinedStatus) {
      firstItem = TimelineChartItem(
        title: R.current.guardian_consent_team_consent_workflow_title_rejected,
        subtitle:
            R.current.guardian_consent_team_consent_workflow_subtitle_rejected,
        state: TimelineChartItemState.declined,
        onTap: () async {
          metrics.track(GuardianConsentResetConsentTapped());
          await resetToConsentRequested(workflow);
        },
      );
      secondItem = TimelineChartItem(
        title: R.current.guardian_consent_team_dependent_info_workflow_title,
        subtitle:
            R.current.guardian_consent_team_dependent_info_workflow_subtitle,
        state: TimelineChartItemState.notStarted,
        onTap: null,
      );
    } else if (workflowStatus is FusionGuardianIntakeDependentInfoStatus) {
      firstItem = TimelineChartItem(
        title: R.current.guardian_consent_team_consent_workflow_title,
        subtitle: teenConsentSubtitle(workflowStatus),
        state: TimelineChartItemState.completed,
        onTap: null,
      );
      secondItem = TimelineChartItem(
        title: R.current.guardian_consent_team_dependent_info_workflow_title,
        subtitle:
            R.current.guardian_consent_team_dependent_info_workflow_subtitle,
        state: TimelineChartItemState.inProgress,
        onTap: () {
          metrics.track(GuardianConsentProvideDependentInfoTapped());
          var deeplink = workflowStatus.deeplink;
          queueDeeplink(deeplink);
        },
      );
    } else if (workflowStatus is FusionGuardianIntakeCompletedStatus) {
      firstItem = TimelineChartItem(
        title: R.current.guardian_consent_team_consent_workflow_title,
        subtitle: teenConsentSubtitle(workflowStatus),
        state: TimelineChartItemState.completed,
        onTap: null,
      );
      secondItem = TimelineChartItem(
        title: R.current.guardian_consent_team_dependent_info_workflow_title,
        subtitle:
            R.current.guardian_consent_team_dependent_info_workflow_subtitle,
        state: TimelineChartItemState.completed,
        onTap: null,
      );
      metrics.track(GuardianConsentRedirectToHeadspace());
      var deviceLaunchUtil = serviceLocator.get<DeviceLaunchUtil>() as WebLaunchUtilImpl;
      unawaited(deviceLaunchUtil.launch('https://headspace.com', newTabOnWeb: false));
    }
  }

  Future<void> resetToConsentRequested(FusionWorkflow workflow) async {
    busy = true;
    notifyListeners();
    try {
      await resetWorkflow(workflow);
      await loadState();
    }
    finally {
      busy = false;
      notifyListeners();
    }
  }

  String teenConsentSubtitle(FusionGuardianConsentWorkflowStatus workflowStatus) {
    if (workflowStatus.consentStatus == 'consent_granted_coaching_only') {
      return R.current
          .guardian_consent_team_consent_workflow_subtitle_coaching_only;
    }
    if (workflowStatus.consentStatus ==
        'consent_granted_coaching_and_therapy') {
      return R.current
          .guardian_consent_team_consent_workflow_subtitle_coaching_therapy;
    }
    return R.current.guardian_consent_team_consent_workflow_subtitle;
  }

  void queueDeeplink(DeepLink deeplink) {
    var event = DeepLinkEvent(deeplink);
    var deeplinkService = serviceLocator.get<DeepLinkService>();
    deeplinkService.postOnboardEvents.add(event);
  }

  void showErrorDialog(String message, {Function onDismiss}) {
    api.modalService.showImmediately(HSCustomAlertModal(
      body: message,
      actions: [
        AlertActionConfig(
          text: R.current.ok,
          onPressed: () {
            onDismiss?.call();
          },
          isDefaultAction: true,
        )
      ],
    ));
  }

  void emailSupport() {
    LaunchUtil.launchEmail(
      emailAddress: R.current.team_support_email_address,
      subject: R.current.guardian_consent_team_support_email_title,
      onError: () {
        showMessageDialog();
      },
    );
  }

  void showMessageDialog() {
    var modalService = serviceLocator.get<ModalService>();

    modalService.showImmediately(
      HSCustomAlertModal(
        body: R.current.contact_help_email_launch_failed,
        actions: [
          AlertActionConfig(
            text: R.current.ok,
          ),
        ],
      ),
    );
  }

  Future<void> resetWorkflow(FusionWorkflow workflow) async {
    var workflowEvent = WorkflowEvent(
        id: workflow.id,
        type: workflow.name,
        action: 'reinitialize_workflow');

    await api.sendWorkflowEvent(workflowEvent);
  }

  void onServiceEvent(ServiceEvent event) {
    switch (event.name) {
      case ServiceEvent.synchronizedContentEvent:
        final contentEvent = event.payload as ContentEvent;
        if (contentEvent.name == 'complete') {
          unawaited(loadState());
        }
        break;
      case ServiceEvent.completedContentEvent:
        final contentEvent = event.payload as ContentEvent;
        /// If the recently presented activity fires this a completed content
        /// event, it indicates for awaiting period for network actions that
        /// follows. Hence we show a loading state.
        break;
      case ServiceEvent.closedWebContent:
        break;
    }
  }

  @override
  void dispose() {
    serviceEventSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadState() async {
    var workflowHash = await serviceLocator.getAsync<String>(
      instanceName: 'workflowHash',
    );
    return loadFusionGuardianIntakeWorkflow(workflowHash);
  }
}
