import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/models/tz_provider.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:flutter/foundation.dart';

enum Origin {
  launch,
  webScheduler,
  content,
  guardianConsent,
  teenClinicalEscalation,
}

enum PageName {
  loading,
}



///sub-events defined alphabetically
class AppLaunchEvent extends Event {
  int userId;

  AppLaunchEvent({this.userId}) : super("Launched App") {
    addProperty(name: 'origin', value: describeEnum(Origin.launch));

    if (userId != null) addProperty(name: 'user_id', value: userId);
  }
}

class OpenedAppEvent extends Event {
  int userId;

  OpenedAppEvent({this.userId}) : super("Opened App") {
    addProperty(name: 'origin', value: describeEnum(Origin.launch));

    if (userId != null) addProperty(name: 'user_id', value: userId);
  }
}

class ExitedAppEvent extends Event {
  int userId;

  ExitedAppEvent({this.userId}) : super("Exited App") {
    addProperty(name: 'origin', value: describeEnum(Origin.webScheduler));

    if (userId != null) addProperty(name: 'user_id', value: userId);
  }
}

class WebSchedulerViewed extends Event {
  WebSchedulerViewed() : super("Web Scheduler Viewed") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class WebSchedulerPeakLoadEvent extends Event {
  WebSchedulerPeakLoadEvent() : super("Web Scheduler Peak Load") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class WebSchedulerDateTappedEvent extends Event {
  WebSchedulerDateTappedEvent() : super("Web Scheduler Date Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class WebSchedulerTimeSelectedEvent extends Event {
  final DateTime dateTime;

  WebSchedulerTimeSelectedEvent({this.dateTime}) : super("Web Scheduler Time Selected") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));

    if (dateTime != null) {
      var d = dateTime.toLocal();
      addProperty(name: "date_time", value: d.toString());
      var timezone = serviceLocator.get<TZProvider>().deviceTimeZone ?? d.timeZoneName;
      addProperty(name: "timezone", value: timezone);
    }
  }
}

class WebSchedulerBookTappedEvent extends Event {
  final DateTime dateTime;

  WebSchedulerBookTappedEvent({this.dateTime}) : super("Book appointment CTA") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));

    if (dateTime != null) {
      var d = dateTime.toLocal();
      addProperty(name: "date_time", value: d.toString());
      var timezone = serviceLocator.get<TZProvider>().deviceTimeZone ?? d.timeZoneName;
      addProperty(name: "timezone", value: timezone);
    }
  }
}

class WebSchedulerDateScrolledEvent extends Event {
  WebSchedulerDateScrolledEvent() : super("Web Scheduler Date Scrolled") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class WebSchedulerTimeScrolledEvent extends Event {
  WebSchedulerTimeScrolledEvent() : super("Web Scheduler Time Scrolled") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class CoachingSessionConfirmationViewedEvent extends Event {
  CoachingSessionConfirmationViewedEvent() : super("Coaching Session Confirmation Viewed") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class CoachingSessionConfirmationBackTappedEvent extends Event {
  CoachingSessionConfirmationBackTappedEvent() : super("Coaching Session Confirmation Back Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class D2cCareOnboardingCloseTapped extends Event {
  D2cCareOnboardingCloseTapped() : super("D2C Care Onboarding Close Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class DownloadHeadspaceTapped extends Event {
  DownloadHeadspaceTapped() : super("Download Headspace CTA") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class AvailableAppointmentsLoaded extends Event {
  final int slots;

  AvailableAppointmentsLoaded({this.slots}) : super("Available Appointments Loaded") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
    addProperty(name: "available_slots", value: slots);
  }
}

class FeelingOverwhelmedAudioPlayed extends Event {
  FeelingOverwhelmedAudioPlayed() : super("Feeling Overwhelmed Audio Played") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class FeelingOverwhelmedAudioStopped extends Event {
  FeelingOverwhelmedAudioStopped() : super("Feeling Overwhelmed Audio Stopped") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class SchedulerSkippedEvent extends Event {
  SchedulerSkippedEvent() : super("Scheduler Skipped - Member Has A Scheduled Session") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
  }
}

class SchedulingFailedEvent extends Event {
  final String reason;

  SchedulingFailedEvent({this.reason}) : super("Web Scheduler - Scheduling Failed Event") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
    addProperty(name: "reason", value: reason);
  }
}

class FailedToLoadAvailableTimesEvent extends Event {
  final String reason;
  final int statusCode;

  FailedToLoadAvailableTimesEvent({this.reason, this.statusCode}) : super("Web Scheduler - Failed To Load Available Times") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
    addProperty(name: "reason", value: reason);

    if (statusCode != null) {
      addProperty(name: "status", value: statusCode);
    }
  }
}

class AuthorizationFailureEvent extends Event {
  final String reason;
  final int statusCode;

  AuthorizationFailureEvent({this.reason, this.statusCode}) : super("Web Scheduler - Authorization Failure") {
    addProperty(name: "origin", value: describeEnum(Origin.webScheduler));
    addProperty(name: "reason", value: reason);

    if (statusCode != null) {
      addProperty(name: "status", value: statusCode);
    }
  }
}

class GuardianConsentViewed extends Event {
  GuardianConsentViewed() : super("Guardian Consent Viewed") {
    addProperty(name: "origin", value: describeEnum(Origin.guardianConsent));
  }
}

class GuardianConsentProvideConsentToServicesTapped extends Event {
  GuardianConsentProvideConsentToServicesTapped() : super("Guardian Consent Provide Consent To Services Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.guardianConsent));
  }
}

class GuardianConsentResetConsentTapped extends Event {
  GuardianConsentResetConsentTapped() : super("Guardian Consent Reset Consent Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.guardianConsent));
  }
}

class GuardianConsentProvideDependentInfoTapped extends Event {
  GuardianConsentProvideDependentInfoTapped() : super("Guardian Consent Provide Dependent Info Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.guardianConsent));
  }
}

class GuardianConsentRedirectToHeadspace extends Event {
  GuardianConsentRedirectToHeadspace() : super("Guardian Consent Redirect To Headspace") {
    addProperty(name: "origin", value: describeEnum(Origin.guardianConsent));
  }
}

class GuardianConsentEmailSupportTapped extends Event {
  GuardianConsentEmailSupportTapped() : super("Guardian Consent Email Support Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.guardianConsent));
  }
}

class ErrorViewed extends Event {
  ErrorViewed() : super("Error Viewed") {
    addProperty(name: "origin", value: describeEnum(Origin.guardianConsent));
  }
}

class ErrorCtaTapped extends Event {
  ErrorCtaTapped() : super("Error CTA Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.guardianConsent));
  }
}

class TeenClinicalEscalationViewed extends Event {
  TeenClinicalEscalationViewed() : super("Teen Clinical Escalation Viewed") {
    addProperty(name: "origin", value: describeEnum(Origin.teenClinicalEscalation));
  }
}

class DependentsSuccessViewed extends Event {
  DependentsSuccessViewed() : super("Dependents Success Viewed") {
    addProperty(name: "origin", value: describeEnum(Origin.teenClinicalEscalation));
  }
}

class DependentsSuccessBackTapped extends Event {
  DependentsSuccessBackTapped() : super("Dependents Success Back Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.teenClinicalEscalation));
  }
}

class DependentsSuccessEmailSupportTapped extends Event {
  DependentsSuccessEmailSupportTapped() : super("Dependents Success Email Support Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.teenClinicalEscalation));
  }
}

class DependentsSuccessFinishTapped extends Event {
  DependentsSuccessFinishTapped() : super("Dependents Success Continue Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.teenClinicalEscalation));
  }
}

class PaymentViewed extends Event {
  PaymentViewed() : super("Payment Viewed") {
    addProperty(name: "origin", value: describeEnum(Origin.teenClinicalEscalation));
  }
}

class PaymentBackTapped extends Event {
  PaymentBackTapped() : super("Payment Back Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.teenClinicalEscalation));
  }
}

class PaymentSubmitTapped extends Event {
  PaymentSubmitTapped() : super("Payment Submit Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.teenClinicalEscalation));
  }
}

class AddCardViewed extends Event {
  AddCardViewed() : super("Add Card Viewed") {
    addProperty(name: "origin", value: describeEnum(Origin.teenClinicalEscalation));
  }
}

class AddCardBackTapped extends Event {
  AddCardBackTapped() : super("Add Card Back Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.teenClinicalEscalation));
  }
}

class AddCardSubmitTapped extends Event {
  AddCardSubmitTapped() : super("Add Card Submit Tapped") {
    addProperty(name: "origin", value: describeEnum(Origin.teenClinicalEscalation));
  }
}