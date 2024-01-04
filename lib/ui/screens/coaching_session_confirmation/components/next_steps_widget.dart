import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_typography.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/ui/widgets/responsive_layout.dart';
import 'package:mini_ginger_web/view_models/coaching_session_confirmation_model.dart';

class NextStepsWidget extends StatelessWidget {
  final CoachingSessionConfirmationModel model;

  const NextStepsWidget({
    Key key,
    @required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: instructions(
        labelStyle: GingerTypography().hs_font_label_l,
        bodyStyle: GingerTypography().hs_font_body_m,
      ),
      tablet: instructions(
        labelStyle: DesktopGingerTypography().desktopLabelMedium,
        bodyStyle: DesktopGingerTypography().desktopBodyMedium,
      ),
      desktop: instructions(
        labelStyle: DesktopGingerTypography().desktopLabelMedium,
        bodyStyle: DesktopGingerTypography().desktopBodyMedium,
      ),
    );
  }

  Widget instructions({
    @required TextStyle labelStyle,
    @required TextStyle bodyStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          R.current.next_steps,
          style: labelStyle,
        ),
        SizedBox(height: 18.dp),
        ...steps(
          labelStyle: labelStyle,
          bodyStyle: bodyStyle,
        ),
      ],
    );
  }

  List<Widget> steps({
    @required TextStyle labelStyle,
    @required TextStyle bodyStyle,
  }) {
    if (model.memberType == 'D2C') {
      return d2cSteps(
        labelStyle: labelStyle,
        bodyStyle: bodyStyle,
      );
    } else if (model.enrollmentFlow == 'fusion') {
      return fusionSteps(
        labelStyle: labelStyle,
        bodyStyle: bodyStyle,
      );
    } else {
      return umdSteps(
        labelStyle: labelStyle,
        bodyStyle: bodyStyle,
      );
    }
  }

  List<Widget> d2cSteps({TextStyle labelStyle, TextStyle bodyStyle}) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.dp),
            child: Image.asset(
              'assets/d2c_turn_on_notifications.webp',
              width: 40.dp,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.current.d2c_next_steps_1_title,
                  style: labelStyle.copyWith(height: 1.2),
                ),
                SizedBox(height: 4.dp),
                Text(
                  R.current.d2c_next_steps_1_description,
                  style: bodyStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> fusionSteps({TextStyle labelStyle, TextStyle bodyStyle}) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.dp),
            child: Image.asset(
              'assets/headspaceIcon.webp',
              width: 40.dp,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.current.coaching_session_confirmation_step_1,
                  style: labelStyle.copyWith(height: 1.2),
                ),
                SizedBox(height: 4.dp),
                Text(
                  model.stepOneDesc,
                  style: bodyStyle,
                ),
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: 24.dp),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.dp),
            child: Image.asset(
              'assets/gingerIcon.webp',
              width: 40.dp,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.current.coaching_session_confirmation_step_2_fusion,
                  style: labelStyle.copyWith(height: 1.2),
                ),
                SizedBox(height: 4.dp),
                Text(
                  R.current.coaching_session_confirmation_step_2_description,
                  style: bodyStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> umdSteps({TextStyle labelStyle, TextStyle bodyStyle}) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.dp),
            child: Image.asset(
              'assets/headspaceIcon.webp',
              width: 40.dp,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.current.coaching_session_confirmation_step_1,
                  style: labelStyle.copyWith(height: 1.2),
                ),
                SizedBox(height: 4.dp),
                Text(
                  model.stepOneDesc,
                  style: bodyStyle,
                ),
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: 24.dp),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.dp),
            child: Image.asset(
              'assets/headspaceCareIcon.webp',
              width: 40.dp,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.current.coaching_session_confirmation_step_2_umd,
                  style: labelStyle.copyWith(height: 1.2),
                ),
                SizedBox(height: 4.dp),
                Text(
                  R.current.coaching_session_confirmation_step_2_description,
                  style: bodyStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }
}
