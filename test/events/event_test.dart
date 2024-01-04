import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/analytics/event.dart';

void main() {
  group('Guardian Consent related event tests', () {
    test('GuardianConsentViewed test', () {
      // GIVEN event
      var event = GuardianConsentViewed();

      // THEN event
      expect(event.eventName, "Guardian Consent Viewed");
      expect(event.props['origin'], describeEnum(Origin.guardianConsent));
    });

    test('GuardianConsentProvideConsentToServicesTapped test', () {
      // GIVEN event
      var event = GuardianConsentProvideConsentToServicesTapped();

      // THEN event
      expect(event.eventName, "Guardian Consent Provide Consent To Services Tapped");
      expect(event.props['origin'], describeEnum(Origin.guardianConsent));
    });

    test('GuardianConsentResetConsentTapped test', () {
      // GIVEN event
      var event = GuardianConsentResetConsentTapped();

      // THEN event
      expect(event.eventName, "Guardian Consent Reset Consent Tapped");
      expect(event.props['origin'], describeEnum(Origin.guardianConsent));
    });

    test('GuardianConsentProvideDependentInfoTapped test', () {
      // GIVEN event
      var event = GuardianConsentProvideDependentInfoTapped();

      // THEN event
      expect(event.eventName, "Guardian Consent Provide Dependent Info Tapped");
      expect(event.props['origin'], describeEnum(Origin.guardianConsent));
    });

    test('GuardianConsentRedirectToHeadspace test', () {
      // GIVEN event
      var event = GuardianConsentRedirectToHeadspace();

      // THEN event
      expect(event.eventName, "Guardian Consent Redirect To Headspace");
      expect(event.props['origin'], describeEnum(Origin.guardianConsent));
    });

    test('GuardianConsentEmailSupportTapped test', () {
      // GIVEN event
      var event = GuardianConsentEmailSupportTapped();

      // THEN event
      expect(event.eventName, "Guardian Consent Email Support Tapped");
      expect(event.props['origin'], describeEnum(Origin.guardianConsent));
    });

    test('ErrorViewed test', () {
      // GIVEN event
      var event = ErrorViewed();

      // THEN event
      expect(event.eventName, "Error Viewed");
      expect(event.props['origin'], describeEnum(Origin.guardianConsent));
    });

    test('ErrorCtaTapped test', () {
      // GIVEN event
      var event = ErrorCtaTapped();

      // THEN event
      expect(event.eventName, "Error CTA Tapped");
      expect(event.props['origin'], describeEnum(Origin.guardianConsent));
    });
  });

  group('Teen Clinical Escalation related event tests', () {
    test('TeenClinicalEscalationViewed test', () {
      // GIVEN event
      var event = TeenClinicalEscalationViewed();

      // THEN event
      expect(event.eventName, "Teen Clinical Escalation Viewed");
      expect(event.props['origin'], describeEnum(Origin.teenClinicalEscalation));
    });

    test('PaymentViewed test', () {
      // GIVEN event
      var event = PaymentViewed();

      // THEN event
      expect(event.eventName, "Payment Viewed");
      expect(event.props['origin'], describeEnum(Origin.teenClinicalEscalation));
    });

    test('PaymentBackTapped test', () {
      // GIVEN event
      var event = PaymentBackTapped();

      // THEN event
      expect(event.eventName, "Payment Back Tapped");
      expect(event.props['origin'], describeEnum(Origin.teenClinicalEscalation));
    });

    test('PaymentSubmitTapped test', () {
      // GIVEN event
      var event = PaymentSubmitTapped();

      // THEN event
      expect(event.eventName, "Payment Submit Tapped");
      expect(event.props['origin'], describeEnum(Origin.teenClinicalEscalation));
    });

    test('AddCardViewed test', () {
      // GIVEN event
      var event = AddCardViewed();

      // THEN event
      expect(event.eventName, "Add Card Viewed");
      expect(event.props['origin'], describeEnum(Origin.teenClinicalEscalation));
    });

    test('AddCardBackTapped test', () {
      // GIVEN event
      var event = AddCardBackTapped();

      // THEN event
      expect(event.eventName, "Add Card Back Tapped");
      expect(event.props['origin'], describeEnum(Origin.teenClinicalEscalation));
    });

    test('AddCardSubmitTapped test', () {
      // GIVEN event
      var event = AddCardSubmitTapped();

      // THEN event
      expect(event.eventName, "Add Card Submit Tapped");
      expect(event.props['origin'], describeEnum(Origin.teenClinicalEscalation));
    });

    test('DependentsSuccessViewed test', () {
      // GIVEN event
      var event = DependentsSuccessViewed();

      // THEN event
      expect(event.eventName, "Dependents Success Viewed");
      expect(event.props['origin'], describeEnum(Origin.teenClinicalEscalation));
    });

    test('DependentsSuccessBackTapped test', () {
      // GIVEN event
      var event = DependentsSuccessBackTapped();

      // THEN event
      expect(event.eventName, "Dependents Success Back Tapped");
      expect(event.props['origin'], describeEnum(Origin.teenClinicalEscalation));
    });

    test('DependentsSuccessEmailSupportTapped test', () {
      // GIVEN event
      var event = DependentsSuccessEmailSupportTapped();

      // THEN event
      expect(event.eventName, "Dependents Success Email Support Tapped");
      expect(event.props['origin'], describeEnum(Origin.teenClinicalEscalation));
    });

    test('DependentsSuccessEmailContinueTapped test', () {
      // GIVEN event
      var event = DependentsSuccessFinishTapped();

      // THEN event
      expect(event.eventName, "Dependents Success Continue Tapped");
      expect(event.props['origin'], describeEnum(Origin.teenClinicalEscalation));
    });
  });
}