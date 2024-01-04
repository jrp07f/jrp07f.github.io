import 'package:care_dart_sdk/ui/controls/primary_button.dart';
import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:care_dart_sdk/ui/templates/headers/basic_header.dart';
import 'package:care_dart_sdk/ui/templates/screens/basic_screen_template.dart';
import 'package:flutter/material.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/coaching_session_confirmation_screen.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/eap_widget.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/next_steps_widget.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/talk_soon_card.dart';
import 'package:mini_ginger_web/ui/widgets/header_title.dart';
import 'package:mini_ginger_web/view_models/coaching_session_confirmation_model.dart';

class MobileCoachingSessionConfirmationScreen extends StatelessWidget {
  final CoachingSessionConfirmationModel model;
  final CoachingSessionConfirmationScreenCallback callback;

  const MobileCoachingSessionConfirmationScreen(
    this.model, {
    @required this.callback,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScreenTemplate(
      header: BasicHeader.withLabel(
        label: '',
        showBackArrowButton: false,
        showCloseButton: false,
      ),
      child: Container(
        child: body(context),
      ),
      footer: footer(context),
    );
  }

  Widget body(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 24.dp),
              child: Image.asset(
                callback.headerAssetPath,
                excludeFromSemantics: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: HeaderTitle(
                  text: R.current.coaching_session_confirmation_title),
            ),
            SizedBox(height: 16.dp),
            model.scheduledTime != null
                ? Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 14.dp,
                            right: 14.dp,
                            top: 24.0,
                            bottom: 32.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(21.0),
                            color: GingerCorePalette.yellow200,
                          ),
                          width: double.infinity,
                          child: TalkSoonCard(model: model),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
            SizedBox(height: 32.dp),
            NextStepsWidget(model: model),
            if (model.hasEapPrivilege)
              EapWidget(model: model, onEapCtaTapped: callback.onEapCtaTapped),
            SizedBox(height: 32.dp),
            model.email != null
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.dp),
                    child: Text(
                      R.current.coaching_session_confirmation_instructions(
                          model.email ?? ''),
                      textAlign: TextAlign.center,
                      style: GingerTypography().hs_font_body_s.copyWith(
                            color: GingerCorePalette.foregroundWeaker,
                          ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget footer(BuildContext context) {
    return Container(
      color: GingerCorePalette.white,
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 32.dp,
      ),
      child: Column(
        children: [
          PrimaryButton.medium(
            key: const ValueKey('DownloadHeadspaceButton'),
            title: callback.submitText,
            isFullWidth: true,
            onTap: callback.onSubmitTapped,
          ),
        ],
      ),
    );
  }
}
