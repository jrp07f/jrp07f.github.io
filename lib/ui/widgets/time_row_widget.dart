import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:mini_ginger_web/commons/ginger_core_palette.dart';
import 'package:mini_ginger_web/models/scheduler_slots.dart';

class TimeRowWidget extends StatelessWidget {
  final SchedulerTime _time;
  final Function _didSelectTime;
  final String timezoneName;
  final bool isFirst;

  const TimeRowWidget(this._time, this._didSelectTime, this.timezoneName,
      {this.isFirst = false, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      hint: R.current.semantics_calendar_date_hint,
      child: InkWell(
        excludeFromSemantics: true,
        onTap: () {
          _didSelectTime(_time);
          SemanticsService.announce(
            R.current.semantics_time_selected_announcement,
            TextDirection.ltr,
          );
        },
        child: Container(
          height: 48.dp,
          decoration: BoxDecoration(
            color: _time.isSelected
                ? GingerCorePalette.grey10
                : GingerCorePalette.white,
            border: Border.all(
              color: GingerCorePalette.grey10,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(80.0),
          ),
          margin: EdgeInsets.only(top: 12.dp),
          alignment: Alignment.center,
          child: Text(
            '${_time.timeOfDay} $timezoneName',
            textAlign: TextAlign.center,
            style: GingerTypography().hs_font_label_m,
          ),
        ),
      ),
    );
  }
}