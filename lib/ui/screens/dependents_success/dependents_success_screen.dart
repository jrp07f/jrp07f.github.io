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
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:mini_ginger_web/view_models/dependents_success_model.dart';

class DependentsSuccessScreen extends StatefulWidget {
  final DependentsSuccessModel model;

  const DependentsSuccessScreen({this.model, Key key}) : super(key: key);

  @override
  State<DependentsSuccessScreen> createState() =>
      _DependentsSuccessScreenState();
}

class _DependentsSuccessScreenState extends State<DependentsSuccessScreen> {
  final metrics = serviceLocator.get<MetricsProvider>();
  DependentsSuccessModel model;

  @override
  void initState() {
    model = widget.model ?? DependentsSuccessModel();
    metrics.track(DependentsSuccessViewed());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GingerCorePalette.white,
      body: SafeArea(
        child: ModelProvider<DependentsSuccessModel>(
          model: model,
          child: ModelBuilder<DependentsSuccessModel>(
            builder: (context, model, child) {
              return BasicScreenTemplate.withCTA(
                header: BasicHeader.withProgressBar(
                  progress: 1.00,
                  showBackArrowButton: false,
                  showCloseButton: false,
                  backAction: () {
                    metrics.track(DependentsSuccessBackTapped());
                    Navigator.of(context).pop();
                  },
                ),
                child: Container(
                  padding: EdgeInsets.all(24.dp),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/dependentsSuccess.webp',
                        width: 156.dp,
                      ),
                      SizedBox(height: 24.dp),
                      Text(
                        R.current.dependents_success_title,
                        style: GingerTypography().hs_font_heading_l,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.dp),
                      Text(
                        R.current.dependents_success_subtitle,
                        style: GingerTypography().hs_font_body_l,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40.dp),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            R.current.next_steps,
                            style: GingerTypography().hs_font_heading_s,
                          ),
                          SizedBox(height: 12.dp),
                          BulletPointText(
                            R.current.dependents_success_step_1_title,
                            textStyle: GingerTypography().hs_font_label_m,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18.dp),
                            child: Text(
                              R.current.dependents_success_step_1_description,
                              style: GingerTypography().hs_font_body_s,
                            ),
                          ),
                          SizedBox(height: 16.dp),
                          BulletPointText(
                            R.current.dependents_success_step_2_title,
                            textStyle: GingerTypography().hs_font_label_m,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18.dp),
                            child: Text(
                              R.current.dependents_success_step_2_description,
                              style: GingerTypography().hs_font_body_s,
                            ),
                          ),
                          SizedBox(height: 16.dp),
                          BulletPointText(
                            R.current.dependents_success_step_3_title,
                            textStyle: GingerTypography().hs_font_label_m,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18.dp),
                            child: Text(
                              R.current.dependents_success_step_3_description,
                              style: GingerTypography().hs_font_body_s,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 74.dp),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 18.dp),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: R.current
                                      .if_you_experience_any_issues('')),
                              TextSpan(
                                text: R.current.team_support_email_address,
                                style:
                                    GingerTypography().hs_font_body_s.copyWith(
                                          color: HeadspacePalette
                                              .lightModeForegroundLink,
                                          decoration: TextDecoration.underline,
                                        ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = onTapEmailSupport,
                              ),
                              const TextSpan(text: "."),
                            ],
                          ),
                          key: const Key('support_email'),
                          style: GingerTypography().hs_font_body_s.copyWith(
                                color:
                                    HeadspacePalette.lightModeForegroundWeaker,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
                ctaTitle: R.current.finish,
                onTapCTA: () {
                  onTapContinue();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void onTapEmailSupport() {
    metrics.track(DependentsSuccessEmailSupportTapped());
    model.emailSupport();
  }

  void onTapContinue() {
    metrics.track(DependentsSuccessFinishTapped());
    model.redirectToHeadspace();
  }
}
