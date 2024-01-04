import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class LinearProgressBar extends StatelessWidget {
  final double percent;

  const LinearProgressBar({
    @required this.percent,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      alignment: MainAxisAlignment.center,
      animation: true,
      percent: percent,
      barRadius: const Radius.circular(32.0),
      lineHeight: 4.dp,
      padding: EdgeInsets.zero,
      backgroundColor: HeadspacePalette.lightModeInteractiveStronger,
      progressColor: HeadspacePalette.orange500,
    );
  }
}
