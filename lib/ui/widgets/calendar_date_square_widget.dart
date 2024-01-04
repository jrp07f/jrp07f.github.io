import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_typography.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:mini_ginger_web/models/scheduler_slots.dart';
import 'package:mini_ginger_web/ui/widgets/responsive_layout.dart';

class CalendarDateSquareWidget extends StatelessWidget {
  final SchedulerDate date;
  final Function didSelectDate;
  final bool selected;

  const CalendarDateSquareWidget(
      {@required this.date,
      @required this.didSelectDate,
      Key key,
      this.selected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: dateSquare(
        width: 60.dp,
        height: 64.dp,
        gap: 8.dp,
        dayOfWeekStyle: GingerTypography().hs_font_label_s,
        dayOfMonthStyle: GingerTypography().hs_font_heading_s,
        cornerRadius: 16.0,
        border: 2.0,
      ),
      tablet: dateSquare(
        width: 99.dp,
        height: 99.dp,
        gap: 16.dp,
        dayOfWeekStyle: DesktopGingerTypography().desktopLabelLarge,
        dayOfMonthStyle: DesktopGingerTypography().desktopHeadingMedium,
        cornerRadius: 24.0,
        border: 3.0,
      ),
      desktop: dateSquare(
        width: 90.dp,
        height: 96.dp,
        gap: 24.dp,
        dayOfWeekStyle: DesktopGingerTypography().desktopLabelLarge,
        dayOfMonthStyle: DesktopGingerTypography().desktopHeadingMedium,
        cornerRadius: 24.0,
        border: 3.0,
      ),
    );
  }

  Widget dateSquare({
    @required double width,
    @required double height,
    @required double gap,
    @required TextStyle dayOfWeekStyle,
    @required TextStyle dayOfMonthStyle,
    @required double cornerRadius,
    @required double border,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label:
          '${date.semanticDayOfWeek}: ${date.semanticMonth}: ${date.dayOfMonth}',
      hint: R.current.semantics_double_tap_to_select,
      onTap: () {
        didSelectDate(date);
      },
      excludeSemantics: true,
      child: Container(
        margin: EdgeInsets.only(right: gap.dp),
        child: Material(
          color: GingerCorePalette.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(cornerRadius),
            onTap: () {
              didSelectDate(date);
            },
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                  color: selected
                      ? GingerCorePalette.blue200
                      : HeadspacePalette.lightModeInteractiveStrong,
                  borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
                  border: !selected
                      ? Border.all(
                          width: 2.0, color: HeadspacePalette.lightModeInteractiveStrong)
                      : Border.all(
                          width: 2.0, color: GingerCorePalette.blue200)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    date.dayOfWeek,
                    style: selected
                        ? dayOfWeekStyle.copyWith(
                            color: GingerCorePalette.white)
                        : dayOfWeekStyle.copyWith(
                            color: GingerCorePalette.warmGrey700),
                  ),
                  Text(
                    date.dayOfMonth,
                    textScaleFactor: 1.0,
                    style: selected
                        ? dayOfMonthStyle.copyWith(
                            color: GingerCorePalette.white)
                        : dayOfMonthStyle.copyWith(
                            color: GingerCorePalette.warmGrey700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
