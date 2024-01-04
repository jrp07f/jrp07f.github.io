import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/analytics/event.dart';

void main() {
  group('Web Scheduler events', () {
    group('Coach Scheduler Screen events', () {
      test(
          "It should construct WebSchedulerViewed object with the correct properties.",
          () async {
        // Given no parameters

        // When the event is initialized
        var event = WebSchedulerViewed();

        // Then, it should construct the schema with correct event name and properties.
        expect(event.eventName, "Web Scheduler Viewed");
        expect(event.props['origin'], "webScheduler");
      });

      test(
          "It should construct WebSchedulerPeakLoadEvent object with the correct properties.",
          () async {
        // Given no parameters

        // When the event is initialized
        var event = WebSchedulerPeakLoadEvent();

        // Then, it should construct the schema with correct event name and properties.
        expect(event.eventName, "Web Scheduler Peak Load");
        expect(event.props['origin'], "webScheduler");
      });

      test(
          "It should construct WebSchedulerBookTappedEvent object with the correct properties.",
          () async {
        // Given no parameters

        // When the event is initialized
        var event = WebSchedulerBookTappedEvent();

        // Then, it should construct the schema with correct event name and properties.
        expect(event.eventName, "Book appointment CTA");
        expect(event.props['origin'], "webScheduler");
      });

      test(
          "It should construct WebSchedulerDateTappedEvent object with the correct properties.",
          () async {
        // Given no parameters

        // When the event is initialized
        var event = WebSchedulerDateTappedEvent();

        // Then, it should construct the schema with correct event name and properties.
        expect(event.eventName, "Web Scheduler Date Tapped");
        expect(event.props['origin'], "webScheduler");
      });

      test(
          "It should construct WebSchedulerTimeTappedEvent object with the correct properties.",
          () async {
        // Given no parameters

        // When the event is initialized
        var event = WebSchedulerTimeSelectedEvent();

        // Then, it should construct the schema with correct event name and properties.
        expect(event.eventName, "Web Scheduler Time Selected");
        expect(event.props['origin'], "webScheduler");
      });

      test(
          "It should construct WebSchedulerDateScrolledEvent object with the correct properties.",
          () async {
        // Given no parameters

        // When the event is initialized
        var event = WebSchedulerDateScrolledEvent();

        // Then, it should construct the schema with correct event name and properties.
        expect(event.eventName, "Web Scheduler Date Scrolled");
        expect(event.props['origin'], "webScheduler");
      });

      test(
          "It should construct WebSchedulerTimeScrolledEvent object with the correct properties.",
          () async {
        // Given no parameters

        // When the event is initialized
        var event = WebSchedulerTimeScrolledEvent();

        // Then, it should construct the schema with correct event name and properties.
        expect(event.eventName, "Web Scheduler Time Scrolled");
        expect(event.props['origin'], "webScheduler");
      });
    });

    group('Coaching Session Confirmation Screen events', () {
      test(
          "It should construct CoachingSessionConfirmationViewedEvent object with the correct properties.",
          () async {
        // Given no parameters

        // When the event is initialized
        var event = CoachingSessionConfirmationViewedEvent();

        // Then, it should construct the schema with correct event name and properties.
        expect(event.eventName, "Coaching Session Confirmation Viewed");
        expect(event.props['origin'], "webScheduler");
      });

      test(
          "It should construct CoachingSessionConfirmationBackTappedEvent object with the correct properties.",
          () async {
        // Given no parameters

        // When the event is initialized
        var event = CoachingSessionConfirmationBackTappedEvent();

        // Then, it should construct the schema with correct event name and properties.
        expect(event.eventName, "Coaching Session Confirmation Back Tapped");
        expect(event.props['origin'], "webScheduler");
      });

      test(
          "It should construct D2cCareOnboardingCloseTapped object with the correct properties.",
          () async {
        // Given no parameters

        // When the event is initialized
        var event = D2cCareOnboardingCloseTapped();

        // Then, it should construct the schema with correct event name and properties.
        expect(event.eventName, "D2C Care Onboarding Close Tapped");
        expect(event.props['origin'], "webScheduler");
      });

      test(
          "It should construct DownloadHeadspaceTapped object with the correct properties.",
          () async {
        // Given no parameters

        // When the event is initialized
        var event = DownloadHeadspaceTapped();

        // Then, it should construct the schema with correct event name and properties.
        expect(event.eventName, "Download Headspace CTA");
        expect(event.props['origin'], "webScheduler");
      });
    });
  });
}
