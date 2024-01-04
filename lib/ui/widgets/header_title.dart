import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_typography.dart';
import 'package:mini_ginger_web/ui/widgets/responsive_layout.dart';

class HeaderTitle extends StatelessWidget {
  final String text;

  const HeaderTitle({
    @required this.text,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: ResponsiveLayout(
        mobile: Text(
          text,
          style: GingerTypography().hs_font_heading_m,
          textAlign: TextAlign.center,
        ),
        tablet: Text(
          text,
          style: DesktopGingerTypography()
              .desktopHeadingMedium,
          textAlign: TextAlign.center,
        ),
        desktop: Text(
          text,
          style: DesktopGingerTypography()
              .desktopHeadingLarge,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
