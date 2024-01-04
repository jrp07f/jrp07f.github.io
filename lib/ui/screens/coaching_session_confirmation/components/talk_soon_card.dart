import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/view_models/coaching_session_confirmation_model.dart';

class TalkSoonCard extends StatelessWidget {
  const TalkSoonCard({
    Key key,
    @required this.model,
  }) : super(key: key);

  final CoachingSessionConfirmationModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          R.current.talk_soon_only,
          style: GingerTypography().hs_font_heading_s,
        ),
        Text(
          R.current.coaching_session_confirmation_card_description(
            model.formattedSessionDate,
            model.formattedSessionTime,
          ),
          style: GingerTypography().hs_font_body_s,
        ),
      ],
    );
  }
}
