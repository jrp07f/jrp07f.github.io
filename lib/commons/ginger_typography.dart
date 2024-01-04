import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';


class DesktopGingerTypography {

  static final DesktopGingerTypography _instance = DesktopGingerTypography._privateConstructor();

  DesktopGingerTypography._privateConstructor();

  factory DesktopGingerTypography() => _instance;

  TextStyle get desktopHeadingLarge => TextStyle(fontSize: 48.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.bold, letterSpacing: -1.2, height: 1.2);
  TextStyle get desktopHeadingMedium => TextStyle(fontSize: 32.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.bold, letterSpacing: -1.2, height: 1.2);

  TextStyle get desktopLabelLarge => TextStyle(fontSize: 20.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.bold, letterSpacing: -0.03, height: 1.5);
  TextStyle get desktopLabelMedium => TextStyle(fontSize: 18.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.bold, letterSpacing: -0.03, height: 1.5);
  TextStyle get desktopLabelSmall => TextStyle(fontSize: 16.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.bold, letterSpacing: -0.03, height: 1.5);
  TextStyle get desktopLabelExtraSmall => TextStyle(fontSize: 14.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.bold, letterSpacing: -0.03, height: 1.5);
  TextStyle get desktopLabel2xs => TextStyle(fontSize: 12.0.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.bold, letterSpacing: -0.03, height: 1.5);
  TextStyle get desktopLabel3xs => TextStyle(fontSize: 10.0.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.bold, letterSpacing: -0.03, height: 1.5);

  TextStyle get desktopBodyLarge => TextStyle(fontSize: 20.0.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.normal, letterSpacing: 0, height: 1.5);
  TextStyle get desktopBodyMedium => TextStyle(fontSize: 18.0.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.normal, letterSpacing: 0, height: 1.5);
  TextStyle get desktopBodySmall => TextStyle(fontSize: 16.0.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.normal, letterSpacing: 0, height: 1.5);
  TextStyle get desktopBodyExtraSmall => TextStyle(fontSize: 14.0.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.normal, letterSpacing: 0, height: 1.5);
  TextStyle get desktopBody2xs => TextStyle(fontSize: 12.0.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.normal, letterSpacing: 0, height: 1.5);
  TextStyle get desktopBody3xs => TextStyle(fontSize: 10.0.dp, fontFamily: "ApercuPro", color: GingerCorePalette.warmGrey700, fontWeight: FontWeight.normal, letterSpacing: 0, height: 1.5);

  TextStyle get desktopLinkLarge => TextStyle(fontSize: 20.0.dp, fontFamily: "ApercuPro", color: HeadspacePalette.lightModePrimary, fontWeight: FontWeight.normal, letterSpacing: 0, height: 1.5);
  TextStyle get desktopLinkMedium => TextStyle(fontSize: 18.0.dp, fontFamily: "ApercuPro", color: HeadspacePalette.lightModePrimary, fontWeight: FontWeight.normal, letterSpacing: 0, height: 1.5);
  TextStyle get desktopLinkSmall => TextStyle(fontSize: 16.0.dp, fontFamily: "ApercuPro", color: HeadspacePalette.lightModePrimary, fontWeight: FontWeight.normal, letterSpacing: 0, height: 1.5);
  TextStyle get desktopLinkExtraSmall => TextStyle(fontSize: 14.0.dp, fontFamily: "ApercuPro", color: HeadspacePalette.lightModePrimary, fontWeight: FontWeight.normal, letterSpacing: 0, height: 1.5);
  TextStyle get desktopLink2xs => TextStyle(fontSize: 12.0.dp, fontFamily: "ApercuPro", color: HeadspacePalette.lightModePrimary, fontWeight: FontWeight.normal, letterSpacing: 0, height: 1.5);

}
