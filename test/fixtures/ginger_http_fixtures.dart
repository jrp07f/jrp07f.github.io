import 'package:care_dart_sdk/models/subscription.dart';
import 'package:flutter/foundation.dart';

class GingerHttpFixtures {
  GingerHttpFixtures._();

  static const String credentialsResponse =
  """{"user_id":216078,"server_secret":"updated_token","has_email":true,"studies":[{"name":"Mood Matters","institution":"Mood Matters","id":113}],"email":"foo@bar.com","has_password":false}""";

  static const String fusionGuardianWorkflowResponseWithLearnStatus =
  """{"success": true,"workflow": {"id": 1,"name": "fusion_guardian_consent_workflow","status": "learn", "payload": {"consent_status": "", "deeplink": "gingerio://content?assignment=1212", "dependent_id": "3"},"version": 1}}""";

  static String fusionGuardianWorkflowResponseWithConsentStatus =
  """{"success": true,"workflow": {"id": 1,"name": "fusion_guardian_consent_workflow","status": "consent", "payload": {"consent_status": "", "deeplink": "gingerio://content?assignment=1212", "dependent_id": "3"},"version": 1}}""";

  static String fusionGuardianWorkflowResponseWithDeclinedStatus =
  """{"success": true,"workflow": {"id": 1,"name": "fusion_guardian_consent_workflow","status": "declined", "payload": {"consent_status": "", "deeplink": "gingerio://content?assignment=1212", "dependent_id": "3"},"version": 1}}""";

  static String fusionGuardianWorkflowResponseWithDependentInfoStatus =
  """{"success": true,"workflow": {"id": 1,"name": "fusion_guardian_consent_workflow","status": "dependent_info", "payload": {"consent_status": "", "deeplink": "gingerio://content?assignment=1212", "dependent_id": "3"},"version": 1}}""";

  static String fusionGuardianWorkflowResponseWithCompletedStatus =
  """{"success": true,"workflow": {"id": 1,"name": "fusion_guardian_consent_workflow","status": "completed", "payload": {"consent_status": ""},"version": 1}}""";

  static String fusionGuardianWorkflowResponseWithUnknownStatus =
  """{"success": true,"workflow": {"id": 1,"name": "fusion_guardian_consent_workflow","status": "unknown", "payload": {"consent_status": ""},"version": 1}}""";

  static const String fusionTeenClinicalEscalationWorkflowResponseWithIntakePendingStatus =
  """{"success": true,"workflow": {"id": 1,"name": "fusion_teen_clinical_escalation_workflow","status": "intake_pending", "payload": {"deeplink": "gingerio://content?assignment=1212"},"version": 1}}""";

  static const String fusionTeenClinicalEscalationWorkflowResponseWithDeclinedStatus =
  """{"success": true,"workflow": {"id": 1,"name": "fusion_teen_clinical_escalation_workflow","status": "declined", "payload": {"deeplink": "gingerio://content?assignment=1212"},"version": 1}}""";

  static const String fusionTeenClinicalEscalationWorkflowResponseWithAuthorizePaymentStatus =
  """{"success": true,"workflow": {"id": 1,"name": "fusion_teen_clinical_escalation_workflow","status": "authorize_payment", "payload": {"deeplink": "gingerio://content?assignment=1212"},"version": 1}}""";

  static const String fusionTeenClinicalEscalationWorkflowResponseWithScheduleAppointmentStatus =
  """{"success": true,"workflow": {"id": 1,"name": "fusion_teen_clinical_escalation_workflow","status": "schedule_appointment", "payload": {"deeplink": "gingerio://content?assignment=1212"},"version": 1}}""";

  static const String fusionTeenClinicalEscalationWorkflowResponseWithReadyStatus =
  """{"success": true,"workflow": {"id": 1,"name": "fusion_teen_clinical_escalation_workflow","status": "ready", "payload": {"deeplink": "gingerio://content?assignment=1212"},"version": 1}}""";


  static String userResponse(
      {SubscriptionStatus subscriptionStatus = SubscriptionStatus.active,
        bool willBeCanceled = false,
        String nextTransactionDate,
        String cost = "0",
        String preferredLanguage,
        bool hasCompletedClinicalAppointment = false}) =>
      """{
    "current_therapy_appointment":null,
    "employer":{"employer_name":"Ginger.io","code":"GingerSnaps"},
    "studies":[{"name":"Mood Matters","institution":"Mood Matters","id":113}],
    "user":{"message-list-version":5,"id":99999,"zip_code":null,"first_name":"Boo","has_email":true,"last_name":"Radley","has_password":false,"email":"","preferred_language":"$preferredLanguage","has_completed_clinical_appointment": $hasCompletedClinicalAppointment},
    "billing_cards":null,
    "subscription":{"plan":{"features":[],"pricing_plans":[{"name":"TEST-Ginger","id":"ginger-coaching"}]},"subscribed_at":"2019-08-23T15:51:16Z","plan_name":"TEST-Ginger","interval_count":1,"currency":"usd","ended_at":null,"cancelled_at":null,"next_transaction":"$nextTransactionDate","id":"","status":"${subscriptionStatus == null ? null : describeEnum(subscriptionStatus)}","interval":"month","cost":"$cost","trial_end":"9999-12-31T23:59:59Z","will_be_canceled":$willBeCanceled,"plan_type":"coaching","previous_employer":null,"can_extend":false,"description":null,"plan_id":"ginger-coaching"},
    "therapist":null,"device_security_enabled":null}""";
}
