import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_core_palette.dart';

class PlatformActivityIndicator extends StatelessWidget {
  const PlatformActivityIndicator(
      {Key key,
      this.color = GingerCorePalette.white,
      this.radius = 12.0})
      : super(key: key);

  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(color),
    );
  }
}
