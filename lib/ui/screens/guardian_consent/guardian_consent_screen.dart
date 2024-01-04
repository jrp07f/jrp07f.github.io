import 'dart:async';

import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/common_widgets/timeline_chart_widget.dart';
import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:care_dart_sdk/ui/templates/headers/basic_header.dart';
import 'package:care_dart_sdk/ui/templates/screens/spotlight_screen_template.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/ui/widgets/full_screen_progress_indicator.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:mini_ginger_web/view_models/fusion_guardian_intake_model.dart';

class GuardianConsentScreen extends StatefulWidget {
  final FusionGuardianConsentModel model;

  const GuardianConsentScreen({this.model, Key key}) : super(key: key);

  @override
  State<GuardianConsentScreen> createState() => _GuardianConsentScreenState();
}

class _GuardianConsentScreenState extends State<GuardianConsentScreen> {
  MetricsProvider metrics;
  FusionGuardianConsentModel model;

  @override
  void initState() {
    model = widget.model ?? FusionGuardianConsentModel();
    unawaited(model.listenToServiceEvents());
    unawaited(model.loadState());
    metrics = serviceLocator.get<MetricsProvider>();
    metrics.track(GuardianConsentViewed());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GingerCorePalette.white,
      body: SafeArea(
        child: ModelProvider<FusionGuardianConsentModel>(
          model: model,
          child: ModelBuilder<FusionGuardianConsentModel>(
            builder: (context, model, child) {
              List<Widget> children = [
                HSSpotlightScreenTemplate(
                  title: R.current.guardian_consent_intermediary_title,
                  imageAsset: 'assets/consentQuestions.webp',
                  header: BasicHeader.withEyebrow(
                    eyebrow: '',
                    label: '',
                    backgroundColor: GingerCorePalette.yellow200,
                    showBackArrowButton: false,
                    showCloseButton: false,
                  ),
                  content: Container(
                    constraints: BoxConstraints(maxWidth: 327.dp),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        timeline,
                        SizedBox(height: 60.dp),
                        footer,
                      ],
                    ),
                  ),
                )
              ];

              if (model.busy) {
                children.add(const FullScreenProgressIndicator());
              }

              return Stack(
                children: children,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget get timeline {
    if (model.firstItem == null || model.secondItem == null) {
      return Container();
    }
    return TimelineChartWidget(
      items: [
        model.firstItem,
        model.secondItem,
      ],
    );
  }

  Widget get footer {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.dp),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: R.current.if_you_experience_any_issues('')),
            TextSpan(
              text: R.current.team_support_email_address,
              style: GingerTypography().hs_font_body_s.copyWith(
                    color: HeadspacePalette.lightModeForegroundLink,
                    decoration: TextDecoration.underline,
                  ),
              recognizer: TapGestureRecognizer()..onTap = emailSupport,
            ),
            const TextSpan(text: "."),
          ],
        ),
        style: GingerTypography().hs_font_body_s.copyWith(
              color: HeadspacePalette.lightModeForegroundWeaker,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void emailSupport() {
    metrics.track(GuardianConsentEmailSupportTapped());
    model.emailSupport();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }
}
