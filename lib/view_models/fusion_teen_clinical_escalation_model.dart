import 'dart:async';

import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/models/content_event.dart';
import 'package:care_dart_sdk/models/workflow.dart';
import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/services/streams/service_events.dart';
import 'package:care_dart_sdk/ui/modals/modal_alert_dialog.dart';
import 'package:care_dart_sdk/ui/shared/ginger_alert_dialog.dart';
import 'package:care_dart_sdk/utilities/deeplink.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mini_ginger_web/navigation/app_routes.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:mini_ginger_web/utilities/web_launch_util.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';

class FusionTeenClinicalEscalationModel extends NavigationModel {
  final log = Logger('FusionTeenClinicalEscalationModel');
  final api = serviceLocator.get<ServiceAPI>() as LocalServiceAPI;

  StreamSubscription<ServiceEvent> serviceEventSubscription;

  FusionWorkflow currentWorkflow;

  Future<void> listenToServiceEvents() async {
    serviceEventSubscription = api.serviceEvents.listen(onServiceEvent);
  }

  Future<void> loadFusionTeenClinicalEscalationWorkflow(String workflowHash) async {
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
    currentWorkflow = workflow;
    var workflowStatus = workflow.status;
    if (workflowStatus is FusionTeenClinicalEscalationIntakePendingStatus) {
      var deeplink = workflowStatus.deeplink;
      queueDeeplink(deeplink);
    } else if (workflowStatus is FusionTeenClinicalEscalationDeclinedStatus) {
      var deviceLaunchUtil = serviceLocator.get<DeviceLaunchUtil>() as WebLaunchUtilImpl;
      unawaited(deviceLaunchUtil.launch('https://headspace.com', newTabOnWeb: false));
    } else if (workflowStatus is FusionTeenClinicalEscalationAuthorizePaymentStatus) {
      api.appRouter.pushNamed(AppRoutes.paymentScreen,
        arguments: AddCardScreenArg(
          enableBackPress: false,
          onCardAdded: (card) async => triggerAuthorizePayment(),
        ),
      );
    } else if (workflowStatus is FusionTeenClinicalEscalationScheduleAppointmentStatus) {
      api.appRouter.pushNamed(AppRoutes.dependentsSuccess);
    } else if (workflowStatus is FusionTeenClinicalEscalationReadyStatus) {
      api.appRouter.pushNamed(AppRoutes.dependentsSuccess);
    }
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
    return loadFusionTeenClinicalEscalationWorkflow(workflowHash);
  }

  Future<void> triggerAuthorizePayment() async {
    if(currentWorkflow.status is! FusionTeenClinicalEscalationAuthorizePaymentStatus) {
      return;
    }
    var workflowStatus = currentWorkflow.status as FusionTeenClinicalEscalationAuthorizePaymentStatus;
    var workflowEvent = WorkflowEvent(
        id: currentWorkflow.id,
        type: currentWorkflow.name,
        action: workflowStatus.action);

    await api.sendWorkflowEvent(workflowEvent);
    await loadState();
  }
}