import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/models/billing_card.dart';
import 'package:care_dart_sdk/models/user.dart';
import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/navigators/common_app_routes.dart';
import 'package:care_dart_sdk/utilities/string_utils.dart';
import 'package:mini_ginger_web/navigation/app_routes.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:logging/logging.dart';
import 'package:stripe_api/stripe_api.dart';
import 'package:stripe_api/stripe_error.dart';

class AddCardModel extends NavigationModel {
  final Logger _log = Logger('AddCardModel');
  User user;
  StripeCard stripeCard;

  String nameError;
  String cardNumberError;
  String expiryError;
  String cvvError;
  String billingZipError;
  String errorCardSave;

  bool isReadOnlyMode = false;
  BillingCard defaultCard;

  bool shouldClearForm = false;

  /// A flag for deciding when to disable or enable the button in the add
  /// billing card mode.
  bool shouldDisableButton = false;

  bool get cardAdded {
    return defaultCard != null &&
        stripeCard != null &&
        defaultCard.cardLastFour ==
            stripeCard.number.substring(stripeCard.number.length - 4);
  }

  final Function(BillingCard) onCardAdded;

  AddCardModel({this.onCardAdded});

  Future<void> load() async {
    var api = serviceLocator.get<ServiceAPI>();
    user = await api.authenticatedUser();

    // Tha main CTA button should be disabled by default since we are in add
    // billing card form mode. It is only re-enabled if all required fields are
    // provided.
    shouldDisableButton = true;

    notifyListeners();
  }

  void goToAddCardClinicalReason() {
    router.pushNamed(CommonAppRoutes.clinicalAddCardReason);
  }

  void actionAttemptAddCard(String name, String cardNumber, String cardExpiry,
      String cardCVV, String billingZip) async {
    metricsProvider.track(SubmitBillingInfo());

    bool canSubmit = true;
    int expiryMonth;
    int expiryYear;

    if (StringUtils.isValidSplitCardExpiry(cardExpiry)) {
      List<String> splitDate = cardExpiry.split('/');
      expiryMonth = int.parse(splitDate[0]);
      expiryYear = int.parse(splitDate[1]);
    }

    stripeCard = StripeCard(
      name: name,
      number: cardNumber.replaceAll(
          RegExp(' +'), ''), // Remove all white spaces in between card number.
      cvc: cardCVV,
      expMonth: expiryMonth,
      expYear: expiryYear,
      addressZip: billingZip,
    );

    ///Expiry check
    if ((StringUtils.isValidSplitCardExpiry(cardExpiry) &&
        stripeCard.validateExpiryDate())) {
      expiryError = null;
    } else {
      canSubmit = false;
      expiryError = R.current.add_payment_invalid_expiry_error;
    }

    ///Number check
    if (stripeCard.validateNumber()) {
      cardNumberError = null;
    } else {
      canSubmit = false;
      cardNumberError = R.current.add_payment_invalid_card_number_error;
    }

    ///CVV check
    if (stripeCard.validateCVC()) {
      cvvError = null;
    } else {
      canSubmit = false;
      cvvError = R.current.add_payment_invalid_cvv_error;
    }

    ///Name check
    if (!StringUtils.isEmpty(name)) {
      nameError = null;
    } else {
      canSubmit = false;
      nameError = R.current.add_payment_invalid_name_error;
    }

    ///Billing check
    if (!StringUtils.isEmpty(billingZip)) {
      billingZipError = null;
    } else {
      canSubmit = false;
      billingZipError = R.current.add_payment_invalid_billing_zip_error;
    }
    notifyListeners();

    if (canSubmit) {
      actionAddCard();
    }
  }

  void actionAddCard() async {
    if (cardAdded) {
      goToNextScreen();
      return;
    }

    busy = true;
    notifyListeners();
    if (stripeCard == null) return;

    try {
      var api = serviceLocator.get<ServiceAPI>();
      var user = (await api.addBillingCardToAccount(stripeCard));
      defaultCard = user.billingCards?.first;

      _log.info("Card successfully added ${user.billingCards}");
      metricsProvider.track(SubmitBillingInfoSuccess());
      if (cardAdded) {
        goToNextScreen();
      } else {
        errorCardSave = R.current.payment_method_cards_digits_error;
        metricsProvider.track(SubmitBillingInfoFailed(null, errorCardSave));
      }
    } on GingerStatusError catch (e, stacktrace) {
      _log.severe(
          "Adding billing card to account failed GingerStatusError: ${e.message}",
          e,
          stacktrace);
      errorCardSave = e.message;
      metricsProvider.track(SubmitBillingInfoFailed(e.statusCode, e.message));
    } on StripeAPIException catch (e, stacktrace) {
      _log.severe(
          "Adding billing card to account failed StripeAPIException: ${e.message}",
          e,
          stacktrace);
      errorCardSave = e.message;
      metricsProvider.track(SubmitBillingInfoFailed(null, e.message));
    } on Exception catch (e, stacktrace) {
      _log.severe(
          "Unexpected error while getting Stripe token $e", e, stacktrace);
      errorCardSave = "";
      metricsProvider.track(SubmitBillingInfoFailed(null, e.toString()));
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void goToNextScreen() {
    if(onCardAdded != null) {
      router.pop();
      onCardAdded(defaultCard);
    }
    else {
      router.pushNamed(AppRoutes.dependentsSuccess);
    }
  }

  void refreshErrors() async {
    //Clears any other errors
    errorCardSave = null;
    cardNumberError = null;
    expiryError = null;
    cvvError = null;
    nameError = null;
    billingZipError = null;

    notifyListeners();
  }

  void maybeToggleButton(String name, String cardNumber, String cardExpiry,
      String cardCVV, String billingZip) {
    if (!isReadOnlyMode) {
      bool disable;

      if (StringUtils.isEmpty(name) ||
          StringUtils.isEmpty(cardNumber) ||
          StringUtils.isEmpty(cardExpiry) ||
          StringUtils.isEmpty(cardCVV) ||
          StringUtils.isEmpty(billingZip)) {
        disable = true;
      } else {
        disable = false;
      }

      // We should only notify listeners if there is a change, else do nothing.
      if (disable != shouldDisableButton) {
        shouldDisableButton = disable;
        notifyListeners();
      }
    }
  }
}