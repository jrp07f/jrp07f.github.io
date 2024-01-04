import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_typography.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/coaching_session_confirmation_screen.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/eap_widget.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/next_steps_widget.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/scan_qr_widget.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/talk_soon_card.dart';
import 'package:mini_ginger_web/ui/widgets/header.dart';
import 'package:mini_ginger_web/ui/widgets/header_title.dart';
import 'package:mini_ginger_web/view_models/coaching_session_confirmation_model.dart';

class TabletCoachingSessionConfirmationScreen extends StatelessWidget {
  final CoachingSessionConfirmationModel model;
  final CoachingSessionConfirmationScreenCallback callback;

  const TabletCoachingSessionConfirmationScreen(
    this.model, {
    @required this.callback,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 60.dp,
            child: Header(
              companyName: model.companyName,
              companyImageUrl: model.companyImageUrl,
            ),
          ),
          SizedBox(height: 16.dp),
          SizedBox(
            width: 554.dp,
            child: Column(
              children: [
                Text(
                  callback.talkSoonMessage,
                  style: DesktopGingerTypography().desktopBodyLarge,
                ),
                SizedBox(height: 12.dp),
                HeaderTitle(
                    text: R.current.coaching_session_confirmation_title),
                SizedBox(height: 16.dp),
                Text(
                  R.current.coaching_session_confirmation_subtitle,
                  style: DesktopGingerTypography()
                      .desktopBodyMedium
                      .copyWith(color: HeadspacePalette.lightModeTextWeak),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 36.dp),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: HeadspacePalette.lightModeBackgroundStrong,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                width: 444.dp,
                padding: EdgeInsets.all(36.dp),
                margin: EdgeInsets.only(bottom: 36.dp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                  child: TalkSoonCard(model: model),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    SizedBox(height: 20.dp),
                    NextStepsWidget(model: model),
                    if (model.hasEapPrivilege)
                      EapWidget(
                          model: model,
                          onEapCtaTapped: callback.onEapCtaTapped),
                    ScanQrWidget(
                        model: model, onSubmitTapped: callback.onSubmitTapped),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
