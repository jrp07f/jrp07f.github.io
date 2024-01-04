import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({@required this.mobile, this.tablet, this.desktop,
    Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// tablet: 705, desktop: 1150, watch: 2560
    double deviceWidth = MediaQuery.of(context).size.width;

    if (deviceWidth >= 1150) {
      return desktop ?? mobile;
    }
    if (deviceWidth >= 710) {
      return tablet ?? mobile;
    }

    return mobile;
  }
}
