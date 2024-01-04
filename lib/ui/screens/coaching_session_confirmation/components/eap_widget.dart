import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_typography.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/ui/widgets/responsive_layout.dart';
import 'package:mini_ginger_web/view_models/coaching_session_confirmation_model.dart';

class EapWidget extends StatelessWidget {
  const EapWidget({
    Key key,
    @required this.model,
    this.onEapCtaTapped,
  }) : super(key: key);
  final CoachingSessionConfirmationModel model;
  final VoidCallback onEapCtaTapped;

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
          R.current.eap_support_title,
          style: labelStyle,
        ),
        SizedBox(height: 18.dp),
        ...renderContent(
          labelStyle: labelStyle,
          bodyStyle: bodyStyle,
        ),
        SizedBox(height: 18.dp),
        SizedBox(
          width: 185.dp,
          height: 30.dp,
          child: ElevatedButton(
            key: const ValueKey("HeadspaceHubRedirectButton"),
            onPressed: onEapCtaTapped,
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300, width: 2.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                )),
            child: Text(
              R.current.eap_support_cta,
              style: ThemeData.light().textTheme.labelSmall,
              textScaleFactor: .7,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> renderContent({TextStyle labelStyle, TextStyle bodyStyle}) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.dp),
            child: Image.asset(
              'assets/eap_platform_icon.webp',
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
                  R.current.eap_support_hub_title,
                  style: labelStyle.copyWith(height: 1.2),
                ),
                SizedBox(height: 4.dp),
                Text(
                  R.current.eap_support_description,
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
