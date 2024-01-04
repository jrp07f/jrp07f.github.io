import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/models/billing_card.dart';
import 'package:care_dart_sdk/models/user.dart';
import 'package:care_dart_sdk/services/network_service/network_responses.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/navigators/common_app_routes.dart';
import 'package:mini_ginger_web/navigation/app_routes.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';

class PaymentModel extends NavigationModel {
  final Logger log = Logger('GingerApp');
  final Function(BillingCard) onCardAdded;

  LocalServiceAPI api;
  bool showBillingCardReasonLink;

  User user;
  bool cardAdded = false;

  String cardNumberText;
  String cardExpiryText;
  BillingCard billingCard;
  String cardNumberSemanticValue;
  String expiryDateSemanticValue;

  PaymentModel(this.onCardAdded);

  Future<void> load() async {
    api = serviceLocator.get<ServiceAPI>() as LocalServiceAPI;
    try {
      user = await api.authenticatedUser();
      log.info("BILLING CARD ${user.billingCards}");

      if (user.billingCards == null || user.billingCards.isEmpty) {
        redirectToAddCard();
        return;
      }

      billingCard = user.billingCards.first;

      cardAdded = true;

      cardNumberText = "•••• •••• •••• ${billingCard.cardLastFour}";
      cardNumberSemanticValue = R.current.semantics_card_number_ending_in(
        billingCard.cardLastFour.split('').join(' '),
      );

      var cardExpMonth = billingCard.cardExpMonth.toString().padLeft(2, '0');
      var yearString = billingCard.cardExpYear.toString().padLeft(2, '0');
      var year = yearString.substring(yearString.length - 2);
      cardExpiryText = "$cardExpMonth/$year";
      expiryDateSemanticValue = DateFormat.yMMMM().format(
        DateTime(billingCard.cardExpYear, billingCard.cardExpMonth),
      );
      notifyListeners();
    } on GingerServiceError catch (e, stacktrace) {
      log.severe(
          "Adding billing card to account failed through Ginger service API call",
          e,
          stacktrace);
    } on Exception catch (e, stacktrace) {
      log.severe("Unexpected error while getting Stripe token", e, stacktrace);
    }
  }

  void goToAddCard() {
    api.appRouter.pushNamed(
      AppRoutes.addCard,
      arguments: AddCardScreenArg(
        enableBackPress: true,
        onCardAdded: (BillingCard card) {
          billingCard = card;
          cardAdded = true;
          notifyListeners();
          onCardAdded(card);
        },
      ),
    );
  }

  void goToAddCardClinicalReason() {
    api.appRouter.pushNamed(CommonAppRoutes.clinicalAddCardReason);
  }

  void redirectToAddCard() {
    api.appRouter.pushReplacementNamed(
      AppRoutes.addCard,
      arguments: AddCardScreenArg(
        enableBackPress: false,
        onCardAdded: onCardAdded,
      ),
    );
  }
}
