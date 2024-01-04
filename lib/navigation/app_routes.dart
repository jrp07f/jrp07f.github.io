import 'package:care_dart_sdk/models/billing_card.dart';
import 'package:care_dart_sdk/services/content_service/main_activity_renderer.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/navigators/common_app_routes.dart';
import 'package:care_dart_sdk/ui/shared/global_keys.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/ui/screens/add_card/add_card_screen.dart';
import 'package:mini_ginger_web/ui/screens/clinical_add_card_reason/clinical_add_card_reason_screen.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/coaching_scheduler_screen.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/coaching_session_confirmation_screen.dart';
import 'package:mini_ginger_web/ui/screens/dependents_success/dependents_success_screen.dart';
import 'package:mini_ginger_web/ui/screens/error/error_screen.dart';
import 'package:mini_ginger_web/ui/screens/ginger_launch_screen.dart';
import 'package:mini_ginger_web/ui/screens/guardian_consent/guardian_consent_screen.dart';
import 'package:mini_ginger_web/ui/screens/payment_screen/payment_screen.dart';
import 'package:mini_ginger_web/ui/screens/teen_clinical_escalation/teen_clinical_escalation_screen.dart';

import 'keys.dart';

class AppRoutes {
  static const start = "/";
  static const error = "/error";
  static const guardianConsent = "/guardian-consent";
  static const scheduler = "/scheduler";
  static const sessionScheduled = "/scheduler/session";
  static const paymentScreen = "/payment";
  static const addCard = "/add-card";
  static const teenClinicalEscalation = "/teen-clinical-escalation";
  static const dependentsSuccess = "/dependents-success";

  static Route getRoute(RouteSettings settings) {
    final String path = settings.name;

    switch (path) {
      case error:
        ErrorScreenArg arg = settings.arguments;
        return _buildRoute(
          settings,
          ErrorScreen(
              title: arg.title, body: arg.body, imagePath: arg.imagePath),
        );
      case guardianConsent:
        return _buildRoute(
          settings,
          GuardianConsentScreen(key: Keys.guardianConsentScreenKey),
        );
      case teenClinicalEscalation:
        return _buildRoute(
          settings,
          TeenClinicalEscalationScreen(key: Keys.teenClinicalEscalationScreenKey),
        );
      case scheduler:
        return _buildRoute(
          settings,
          const CoachingSchedulerScreen(),
        );
      case sessionScheduled:
        ScheduledSessionScreenArg arg = settings.arguments;
        return _buildRoute(
          settings,
          CoachingSessionConfirmationScreen(arg.time),
        );
      case paymentScreen:
        final AddCardScreenArg args = settings.arguments;
        return _buildRoute(
          settings,
          PaymentScreen(
            onCardAdded: args.onCardAdded,
          ),
        );
      case addCard:
        final AddCardScreenArg args = settings.arguments;
        return _buildRoute(
          settings,
          AddCardScreen(
            enableBackPress: args.enableBackPress,
            onCardAdded: args.onCardAdded,
          ),
        );
      case CommonAppRoutes.clinicalAddCardReason:
        return _buildRoute(
          settings,
          const ClinicalAddCardReasonScreen(),
        );
      case CommonAppRoutes.activityRenderer:
        final ActivityRendererScreenArguments args = settings.arguments;
        return _buildRoute(
          settings,
          MainActivityRenderer(
            key: GlobalKeys.activityRendererScreenKey,
            activityMetadata: args?.activityMetadata,
            activity: args?.activity,
          ),
        );
      case dependentsSuccess:
        return _buildRoute(
          settings,
          const DependentsSuccessScreen(),
        );
      case CommonAppRoutes.webViewSinglePage:
        final WebviewSinglePageScreenArguments args = settings.arguments;
        openExternalTabForURL(args.url);
        return null;
      case start:
      default:
        return _buildRoute(
          settings,
          const GingerLaunchScreen(),
        );
    }
  }

  static Route _buildRoute<T extends Object>(
      RouteSettings settings, Widget widget) {
    return MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) {
        return widget;
      },
    );
  }

  static void openExternalTabForURL(String url) async {
    final launchUtil = serviceLocator.get<DeviceLaunchUtil>();
    if (await launchUtil.canLaunch(url)) {
      await launchUtil.launch(url);
      return;
    }
  }
}

class ScheduledSessionScreenArg {
  final DateTime time;

  ScheduledSessionScreenArg(this.time);
}

class ErrorScreenArg {
  final String title;
  final String body;
  final String imagePath;

  ErrorScreenArg({this.title, this.body, this.imagePath});
}

class AddCardScreenArg {
  final bool enableBackPress;
  final Function(BillingCard) onCardAdded;

  AddCardScreenArg({this.enableBackPress, this.onCardAdded});
}