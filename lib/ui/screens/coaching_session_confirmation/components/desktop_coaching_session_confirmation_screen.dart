import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_typography.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/coaching_session_confirmation_screen.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/next_steps_widget.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/eap_widget.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/scan_qr_widget.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/talk_soon_card.dart';
import 'package:mini_ginger_web/ui/widgets/header.dart';
import 'package:mini_ginger_web/ui/widgets/header_title.dart';
import 'package:mini_ginger_web/ui/widgets/linear_progress_bar.dart';
import 'package:mini_ginger_web/view_models/coaching_session_confirmation_model.dart';

class DesktopCoachingSessionConfirmationScreen extends StatelessWidget {
  final CoachingSessionConfirmationModel model;
  final CoachingSessionConfirmationScreenCallback callback;

  const DesktopCoachingSessionConfirmationScreen(
    this.model, {
    @required this.callback,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            height: 82.dp,
            child: Header(
              companyName: model.companyName,
              companyImageUrl: model.companyImageUrl,
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 680.dp,
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.only(top: 144.dp),
                    width: 320.dp,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LinearProgressBar(percent: 1.00),
                        SizedBox(height: 24.dp),
                        Text(
                          callback.talkSoonMessage,
                          style: DesktopGingerTypography().desktopBodyLarge,
                        ),
                        SizedBox(height: 12.dp),
                        HeaderTitle(
                            text:
                                R.current.coaching_session_confirmation_title),
                        SizedBox(height: 16.dp),
                        Text(
                          R.current.coaching_session_confirmation_subtitle,
                          style: DesktopGingerTypography()
                              .desktopBodyLarge
                              .copyWith(
                                  color: HeadspacePalette.lightModeTextWeak),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: HeadspacePalette.lightModeBackgroundStrong,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        width: 420.dp,
                        padding: EdgeInsets.all(36.dp),
                        margin: EdgeInsets.only(
                          top: 144.dp,
                          bottom: 36.dp,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(16.dp),
                                child: Image.asset(
                                  callback.headerAssetPath,
                                  excludeFromSemantics: true,
                                ),
                              ),
                            ),
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
                                            borderRadius:
                                                BorderRadius.circular(21.0),
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
                                model: model,
                                onSubmitTapped: callback.onSubmitTapped),
                          ],
                        ),
                      ),
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
