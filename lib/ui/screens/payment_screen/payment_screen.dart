import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/models/billing_card.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/common_widgets/full_screen_progress_indicator.dart';
import 'package:care_dart_sdk/ui/controls/tertiary_button.dart';
import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:care_dart_sdk/ui/templates/headers/basic_header.dart';
import 'package:care_dart_sdk/ui/templates/screens/basic_screen_template.dart';
import 'package:care_dart_sdk/utilities/ally_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:mini_ginger_web/view_models/payment_model.dart';

class PaymentScreen extends StatefulWidget {
  final PaymentModel model;
  final Function(BillingCard) onCardAdded;

  const PaymentScreen({
    Key key,
    this.model, this.onCardAdded,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() {
    return _PaymentScreenWidgetState();
  }
}

class _PaymentScreenWidgetState extends State<PaymentScreen> {
  PaymentModel paymentModel;
  var metrics = serviceLocator.get<MetricsProvider>();

  @override
  void initState() {
    super.initState();
    metrics.track(PaymentViewed());
    paymentModel = widget.model ?? PaymentModel(widget.onCardAdded);
    paymentModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return ModelProvider<PaymentModel>(
      model: paymentModel,
      child: ModelBuilder<PaymentModel>(builder: (context, model, child) {
        List<Widget> children = [];
        children.add(BasicScreenTemplate.withCTA(
          title: R.current.payment_title,
          titleAlign: TextAlign.left,
          subtitle: R.current.payment_subtitle,
          header: BasicHeader.withProgressBar(
            progress: 0.5,
            showCloseButton: false,
            showBackArrowButton: false,
            backAction: () {
              metrics.track(PaymentBackTapped());
              Navigator.pop(context);
            },
          ),
          ctaTitle: R.current.payment_cta_button,
          ctaColor: GingerCorePalette.warmGrey700,
          onTapCTA: onTapCTA,
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

  void onTapCTA() {
    metrics.track(PaymentSubmitTapped());
    widget.onCardAdded(paymentModel.billingCard);
  }

  Widget buildContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.dp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.dp),
          paymentModel.cardExpiryText != null ? Container(
            padding: EdgeInsets.all(16.dp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.dp),
              color: GingerCorePalette.cloudyWhite,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        label: R.current.card_number,
                        value: paymentModel.cardNumberSemanticValue,
                        excludeSemantics: true,
                        child: Text(
                          paymentModel.cardNumberText,
                          style: GingerTypography().hs_font_label_l.copyWith(
                            color: GingerCorePalette.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.dp),
                      Semantics(
                        label: R.current.expiry_date,
                        value: paymentModel.expiryDateSemanticValue,
                        excludeSemantics: true,
                        child: Text(
                          paymentModel.cardExpiryText,
                          style: GingerTypography().hs_font_body_m.copyWith(
                            color: GingerCorePalette.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.dp),
                Material(
                  color: GingerCorePalette.transparent,
                  child: Semantics(
                    onTapHint: R.current.semantics_activate,
                    hint: AllyUtils.maybeProvideSemanticsHint(R.current.semantics_double_tap_to_activate),
                    onTap: () {
                      paymentModel.goToAddCard();
                    },
                    child: InkWell(
                      excludeFromSemantics: true,
                      onTap: () {
                        paymentModel.goToAddCard();
                      },
                      child: SizedBox(
                        width: 64.dp,
                        child: Text(
                          R.current.payment_edit_button,
                          textAlign: TextAlign.right,
                          style: GingerTypography().hs_font_body_m.copyWith(
                                color: GingerCorePalette.black,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ) : const SizedBox(),
          SizedBox(height: 24.dp),
          GestureDetector(
            onTap: () {
              paymentModel.goToAddCardClinicalReason();
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
                              paymentModel.goToAddCardClinicalReason();
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
}
