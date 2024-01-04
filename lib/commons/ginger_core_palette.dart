import 'package:flutter/material.dart';

class GingerCorePalette {
  static const Color blueBerry = Color(0xFF2875CC);
  static const Color sky = Color(0xFF9EC3EC);
  static const Color periwinkle = Color(0xFF98B6D8);

  static const Color apricot = Color(0xFFF4CE8A);
  static const Color turmeric = Color(0xFFE5AB33);
  static const Color sand = Color(0xFFF9EFD8);

  static const Color chili = Color(0xFFDC3618);
  static const Color rose = Color(0xFFFEE3DE);
  static const Color lightRose = Color(0xFFFFF4F2);

  static const Color lightCloud = Color(0xFFEFF7FF);
  static const Color cloud = Color(0xFFD7EAFF);
  static const Color denim = Color(0xFF609CE1);
  static const Color sea = Color(0xFF254C7E);
  static const Color lightMint = Color(0xFFF2FAF5);
  static const Color mint = Color(0xFFE4F5EA);
  static const Color avocado = Color(0xFFB4DEC4);
  static const Color shamrock = Color(0xFF5BB97F);
  static const Color kelp = Color(0xFF1C7B53);
  static const Color leaf = Color(0xFF235949);
  static const Color coral = Color(0xFFFFBBAF);
  static const Color watermelon = Color(0xFFED705A);
  static const Color plum = Color(0xFFED705A);          // TODO: refactor
  static const Color pomegranate = Color(0xFF963727);

  static const Color black = Color(0xFF191919);
  static const Color grey100 = Color(0xFF191919);
  static const Color grey90 = Color(0xFF272727);
  static const Color grey85 = Color(0xFF474747);
  static const Color grey60 = Color(0xFF7D7D7D);
  static const Color grey45 = Color(0xFF9E9E9E);
  static const Color grey30 = Color(0xFFBEBEBE);
  static const Color grey20 = Color(0xFFD4D4D4);
  static const Color grey15 = Color(0xFFE9E9E9);
  static const Color grey10 = Color(0xFFE9E9E9);
  static const Color grey7 = Color(0xFFF4F4F4);
  static const Color grey8 = Color(0xFFF4F4F4);
  static const Color grey5 = Color(0xFFF4F4F4);
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteDesert = Color(0xFFFDF9F1);
  static const Color transparent = Colors.transparent;

  static const Color modalBackground = Color(0x80191919);

  static List<BoxShadow> appCardDropShadow = [
    BoxShadow(
        color: GingerCorePalette.apricot.withOpacity(0.15),
        offset: const Offset(0.0, 4.0),
        blurRadius: 8.0,
        spreadRadius: 2.0)
  ];

  GingerCorePalette._privateConstructor();
}
