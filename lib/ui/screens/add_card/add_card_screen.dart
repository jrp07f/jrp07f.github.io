import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/models/billing_card.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/common_widgets/full_screen_progress_indicator.dart';
import 'package:care_dart_sdk/ui/controls/input_form_field.dart';
import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:care_dart_sdk/ui/templates/headers/basic_header.dart';
import 'package:care_dart_sdk/ui/templates/screens/basic_screen_template.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mini_ginger_web/view_models/add_card_model.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';

class AddCardScreen extends StatefulWidget {
  final AddCardModel model;
  final bool enableBackPress;
  final Function(BillingCard) onCardAdded;

  const AddCardScreen(
      {Key key, this.model, this.enableBackPress = true, this.onCardAdded})
      : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final cvvMaxLength = 4;
  final billingZipMapLength = 10;

  TextEditingController nameController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController billingZipController = TextEditingController();
  List<TextEditingController> controllers;
  MaskTextInputFormatter cardNumberMask;
  MaskTextInputFormatter expiryMask;

  AddCardModel addCardModel;
  var metrics = serviceLocator.get<MetricsProvider>();

  @override
  void initState() {
    metrics.track(AddCardViewed());
    controllers = [
      nameController,
      cardNumberController,
      expiryDateController,
      cvvController,
      billingZipController,
    ];
    addCardModel =
        widget.model ?? AddCardModel(onCardAdded: widget.onCardAdded);
    addCardModel.load();

    cardNumberMask = MaskTextInputFormatter(
        mask: '#### #### #### ####', filter: {"#": RegExp(r'[0-9]')});
    expiryMask =
        MaskTextInputFormatter(mask: '##/##', filter: {"#": RegExp(r'[0-9]')});

    super.initState();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModelProvider<AddCardModel>(
      model: addCardModel,
      child: ModelBuilder<AddCardModel>(builder: (context, model, child) {
        List<Widget> children = [];
        children.add(BasicScreenTemplate.withCTA(
          title: R.current.add_payment_method_title,
          titleAlign: TextAlign.left,
          subtitle: R.current.add_payment_method_subtitle,
          header: BasicHeader.withProgressBar(
            progress: 0.5,
            showCloseButton: false,
            showBackArrowButton: !widget.enableBackPress,
            backAction: () {
              metrics.track(AddCardBackTapped());
              Navigator.pop(context);
            },
          ),
          ctaTitle: R.current.save_button,
          ctaColor: GingerCorePalette.warmGrey700,
          onTapCTA: addCardModel.shouldDisableButton ? null : onTapCTA,
          child: buildContent(),
        ));
        if (model.busy) {
          children.add(FullScreenProgressIndicator());
        }

        return Stack(
          children: children,
        );
      }),
    );
  }

  Widget buildContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.dp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputFormField(
            formFieldKey: const Key("nameOnCard"),
            autofillHints: const [AutofillHints.creditCardName],
            controller: nameController,
            onTap: () {
              refreshErrors();
            },
            onChanged: (_) {
              maybeEnableSubmitAction();
            },
            labelText: R.current.name_on_card,
            errorText: addCardModel.nameError,
          ),
          SizedBox(height: 12.dp),
          InputFormField(
            formFieldKey: const Key("cardNumber"),
            autofillHints: const [AutofillHints.creditCardNumber],
            controller: cardNumberController,
            inputFormatters: [cardNumberMask],
            onTap: () {
              refreshErrors();
            },
            onChanged: (_) {
              maybeEnableSubmitAction();
            },
            inputType: TextInputType.number,
            labelText: R.current.card_number,
            errorText: addCardModel.cardNumberError,
          ),
          SizedBox(height: 12.dp),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: InputFormField(
                  formFieldKey: const Key("expiryDate"),
                  autofillHints: const [AutofillHints.creditCardExpirationDate],
                  controller: expiryDateController,
                  inputFormatters: [expiryMask],
                  onTap: () {
                    refreshErrors();
                  },
                  onChanged: (value) {
                    maybeEnableSubmitAction();
                  },
                  enableInteractiveSelection: false,
                  inputType:
                      const TextInputType.numberWithOptions(signed: true),
                  labelText: R.current.expiry_date,
                  hintText: R.current.expiry_date_hint,
                  errorText: addCardModel.expiryError,
                ),
              ),
              SizedBox(width: 12.dp),
              Expanded(
                child: InputFormField(
                  formFieldKey: const Key("cvv"),
                  autofillHints: const [AutofillHints.creditCardSecurityCode],
                  controller: cvvController,
                  onTap: () {
                    refreshErrors();
                  },
                  onChanged: (_) {
                    maybeEnableSubmitAction();
                  },
                  enableInteractiveSelection: false,
                  inputType:
                      const TextInputType.numberWithOptions(signed: true),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(cvvMaxLength),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  labelText: R.current.cvv_capped,
                  errorText: addCardModel.cvvError,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.dp),
          InputFormField(
            formFieldKey: const Key("billingZip"),
            autofillHints: const [AutofillHints.postalCode],
            controller: billingZipController,
            onTap: () {
              refreshErrors();
            },
            onChanged: (_) {
              maybeEnableSubmitAction();
            },
            enableInteractiveSelection: false,
            inputType: const TextInputType.numberWithOptions(signed: true),
            inputFormatters: [
              LengthLimitingTextInputFormatter(billingZipMapLength),
              FilteringTextInputFormatter.digitsOnly,
            ],
            labelText: R.current.zip_code,
            errorText: addCardModel.billingZipError,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 12.dp),
          GestureDetector(
            onTap: () {
              addCardModel.goToAddCardClinicalReason();
              metrics.track(
                ClinicalMemberAddBillingCardReasonTappedEvent(),
              );
            },
            excludeFromSemantics: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.dp),
                  child: Image.asset(
                    'assets/info.webp',
                    fit: BoxFit.fitHeight,
                    excludeFromSemantics: true,
                    color: GingerCorePalette.blue200,
                  ),
                ),
                SizedBox(width: 8.dp),
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style: GingerTypography().hs_font_body_m,
                      children: [
                        TextSpan(
                          text:
                              R.current.clinical_add_billing_card_reason_cta,
                          style: GingerTypography().hs_font_body_m.copyWith(
                                color: GingerCorePalette.blue200,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              addCardModel.goToAddCardClinicalReason();
                              metrics.track(
                                ClinicalMemberAddBillingCardReasonTappedEvent(),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onTapCTA() {
    if (addCardModel.isReadOnlyMode) return;

    metrics.track(AddCardSubmitTapped());
    addCardModel.actionAttemptAddCard(
      nameController.text.trim(),
      cardNumberController.text.trim(),
      expiryDateController.text.trim(),
      cvvController.text.trim(),
      billingZipController.text.trim(),
    );
  }

  void refreshErrors() {
    addCardModel.refreshErrors();
  }

  void maybeEnableSubmitAction() {
    addCardModel.maybeToggleButton(
      nameController.text.trim(),
      cardNumberController.text.trim(),
      expiryDateController.text.trim(),
      cvvController.text.trim(),
      billingZipController.text.trim(),
    );
  }
}
