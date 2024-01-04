import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_core_palette.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';

class CheckWidget extends StatelessWidget {
  final bool checked;
  const CheckWidget({Key key, this.checked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (checked) {
      return Container(
        width: 24.dp,
        height: 24.dp,
        decoration: const BoxDecoration(
          color: HeadspacePalette.lightModeInteractiveStaticDark,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 8.dp,
            height: 8.dp,
            decoration: const BoxDecoration(
              color: GingerCorePalette.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 24.dp,
      height: 24.dp,
      decoration: const BoxDecoration(
        color: HeadspacePalette.lightModeBackgroundStrong,
        shape: BoxShape.circle,
      ),
    );
  }
}