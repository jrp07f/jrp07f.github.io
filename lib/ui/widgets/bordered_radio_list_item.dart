import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_core_palette.dart';
import 'package:mini_ginger_web/ui/widgets/check_box_widget.dart';

class BorderedRadioListItem extends StatelessWidget {
  final Function() onTap;
  final String title;
  final String subtext;
  final bool checked;
  final int maxLines;
  final CrossAxisAlignment crossAxisAlignment;
  final Color selectedColor;
  final Color borderColor;

  const BorderedRadioListItem({
    Key key,
    @required this.onTap,
    @required this.title,
    this.subtext,
    this.checked = false,
    this.maxLines = 2,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.selectedColor = GingerCorePalette.grey10,
    this.borderColor = GingerCorePalette.grey10,
  }) : super(key: key);


  bool get radioSemanticsChecked {
    return checked;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.none,
      elevation: 0,
      margin: EdgeInsets.zero,
      color: checked ? selectedColor : null,
      shape: RoundedRectangleBorder(
          side: BorderSide(
            color: borderColor,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(72.0)),
      child: Semantics(
        selected: radioSemanticsChecked,
        label: "$title: ${subtext ?? ''}",
        hint: R.current.semantics_double_tap_select,
        onTap: onTap,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: GingerCorePalette.grey10,
          splashColor: GingerCorePalette.grey20,
          child: Container(
            padding: EdgeInsets.only(
              left: 32.dp,
              right: 16.dp,
              top: 14.5.dp,
              bottom: 14.5.dp,
            ),
            child: Row(
              crossAxisAlignment: crossAxisAlignment,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: maxLines,
                        style: GingerTypography().hs_font_label_m,
                      ),
                      Visibility(
                        visible: subtext != null,
                        child: Container(
                          margin: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            subtext ?? '',
                            style: GingerTypography().hs_font_body_xs.copyWith(
                              color: GingerCorePalette.grey45
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                CheckWidget(checked: checked),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


