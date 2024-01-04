import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_core_palette.dart';

class WebAppTheme {
  WebAppTheme._();

  static ThemeData light() {
    return ThemeData(
      primaryColor: GingerCorePalette.blueBerry,
      disabledColor: GingerCorePalette.grey30,
      fontFamily: 'ApercuPro',
      buttonTheme: const ButtonThemeData(
        focusColor: GingerCorePalette.sea,
        hoverColor: GingerCorePalette.sea,
        disabledColor: GingerCorePalette.grey30,
        padding: EdgeInsets.symmetric(horizontal: 40.0),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GingerCorePalette.blueBerry,
          disabledForegroundColor: GingerCorePalette.grey30.withOpacity(0.38),
          disabledBackgroundColor: GingerCorePalette.grey30.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(72),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          textStyle: GingerTypography().hs_font_label_m
              .copyWith(color: GingerCorePalette.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GingerCorePalette.blueBerry,
          disabledForegroundColor: GingerCorePalette.grey30.withOpacity(0.38),
          backgroundColor: GingerCorePalette.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(72),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          textStyle: GingerTypography().hs_font_label_m
              .copyWith(color: GingerCorePalette.blueBerry),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GingerCorePalette.blueBerry,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(72),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          textStyle: GingerTypography().hs_font_label_s
              .copyWith(color: GingerCorePalette.blueBerry),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: GingerTypography().hs_font_heading_xl,
        displayMedium: GingerTypography().hs_font_heading_l,
        displaySmall: GingerTypography().hs_font_heading_m,
        headlineMedium: GingerTypography().hs_font_heading_s,
        headlineSmall: GingerTypography().hs_font_label_l,
        titleLarge: GingerTypography().hs_font_label_m,
        bodyLarge: GingerTypography().hs_font_body_m,
        bodyMedium: GingerTypography().hs_font_body_s,
        titleMedium: GingerTypography().hs_font_label_m,
        titleSmall: GingerTypography().hs_font_label_s,
        bodySmall: GingerTypography().hs_font_body_xs,
        labelLarge: GingerTypography().hs_font_label_m,
        labelSmall: GingerTypography().hs_font_body_xs,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: GingerCorePalette.grey60,
        brightness: Brightness.light,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: GingerCorePalette.grey60,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: GingerCorePalette.turmeric,
        error: GingerCorePalette.chili,
      ),
    );
  }

  static ThemeData dark() {
    return light().copyWith(
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: GingerCorePalette.grey60,
        brightness: Brightness.dark,
      ),
    );
  }
}