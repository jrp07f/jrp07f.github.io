import 'dart:async';

import 'package:care_dart_sdk/analytics/event.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/common_widgets/bullet_point_text.dart';
import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:care_dart_sdk/ui/templates/headers/basic_header.dart';
import 'package:care_dart_sdk/ui/templates/screens/basic_screen_template.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:mini_ginger_web/view_models/clinical_add_card_reason_model.dart';

class ClinicalAddCardReasonScreen extends StatefulWidget {
  final ClinicalAddCardReasonModel model;

  const ClinicalAddCardReasonScreen({Key key, this.model}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ClinicalAddCardReasonScreenState();
}

class _ClinicalAddCardReasonScreenState
    extends State<ClinicalAddCardReasonScreen> {
  final metricsProvider = serviceLocator.get<MetricsProvider>();

  ClinicalAddCardReasonModel model;

  @override
  void initState() {
    super.initState();
    metricsProvider
        .track(ViewedClinicalMemberAddBillingCardReasonScreenEvent());

    model = widget.model ?? ClinicalAddCardReasonModel();
  }

  @override
  Widget build(BuildContext context) {
    return ModelProvider<ClinicalAddCardReasonModel>(
      model: model,
      child: ModelBuilder<ClinicalAddCardReasonModel>(
          builder: (context, model, child) {
        return BasicScreenTemplate(
          title: R.current.clinical_add_card_reason_screen_title,
          titleAlign: TextAlign.start,
          subtitle: R.current.clinical_add_card_reason_screen_subtitle,
          header: BasicHeader.withLabel(
            label: '',
            backAction: () {
              metricsProvider
                  .track(ClinicalMemberAddBillingCardReasonBackTappedEvent());
              Navigator.pop(context);
            },
            showCloseButton: false,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.dp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.dp),
                    color: GingerCorePalette.cloudyWhite,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/x_circle.webp',
                        fit: BoxFit.fitHeight,
                        width: 24.dp,
                        excludeFromSemantics: true,
                        color: GingerCorePalette.blue200,
                      ),
                      SizedBox(width: 12.dp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              R.current.you_will_only_be_charged_if,
                              style: GingerTypography().hs_font_label_m,
                            ),
                            SizedBox(height: 4.dp),
                            BulletPointText(
                              R.current.charge_reason_1,
                              textStyle: GingerTypography().hs_font_body_s,
                            ),
                            SizedBox(height: 4.dp),
                            BulletPointText(
                              R.current.charge_reason_2,
                              textStyle: GingerTypography().hs_font_body_s,
                            ),
                            SizedBox(height: 4.dp),
                            BulletPointText(
                              R.current.charge_reason_3,
                              textStyle: GingerTypography().hs_font_body_s,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 14.dp),
                              child: Text.rich(TextSpan(
                                  text: R.current.learn_more,
                                  style: GingerTypography()
                                      .hs_font_body_s
                                      .copyWith(
                                        color: GingerCorePalette.blue200,
                                        decoration: TextDecoration.underline,
                                      ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      actionOpenFAQ();
                                    })),
                            ),
                            SizedBox(height: 4.dp),
                            BulletPointText(
                              R.current.charge_reason_4,
                              textStyle: GingerTypography().hs_font_body_s,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.dp),
                Text(
                  R.current.clinical_add_card_reason_screen_footer,
                  style: GingerTypography()
                      .hs_font_body_s
                      .copyWith(color: GingerCorePalette.warmGrey500),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void actionOpenFAQ() async {
    unawaited(model.actionPresentWebLink(url: R.current.global_billing_faq_url));
  }
}
