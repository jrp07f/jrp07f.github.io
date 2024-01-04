import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/coaching_scheduler_screen.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/components/timeslot_list_widget.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/components/footer.dart';
import 'package:mini_ginger_web/ui/widgets/header.dart';
import 'package:mini_ginger_web/ui/widgets/calendar_date_square_widget.dart';
import 'package:mini_ginger_web/ui/widgets/header_title.dart';
import 'package:mini_ginger_web/ui/widgets/linear_progress_bar.dart';
import 'package:mini_ginger_web/view_models/scheduler_model.dart';

class MobileCoachingSchedulerScreen extends StatelessWidget {
  final SchedulerModel model;
  final CoachingSchedulerScreenCallback callback;

  const MobileCoachingSchedulerScreen(this.model, {
    @required this.callback,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 59.dp,
          child: Header(
            companyName: model.companyName,
            companyImageUrl: model.companyImageUrl,
          ),
        ),
        SizedBox(
          child: Column(
            children: [
              SizedBox(height: 20.dp),
              SizedBox(
                width: 88.dp,
                child: const LinearProgressBar(percent: 0.85),
              ),
              SizedBox(height: 24.dp),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: HeaderTitle(text: R.current.coaching_scheduler_title),
              ),
              SizedBox(height: 16.dp),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  R.current.coaching_scheduler_subtitle,
                  style: GingerTypography()
                      .hs_font_body_m
                      .copyWith(color: HeadspacePalette.lightModeTextWeak),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.dp),
        SizedBox(
          height: 64.dp,
          child: NotificationListener<ScrollNotification>(
            onNotification: callback.onDateScroll,
            child: Semantics(
              label: R.current.semantics_date_selector_slider_label,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 24, right: 12),
                scrollDirection: Axis.horizontal,
                controller: callback.dateController,
                itemCount: model.visibleDateSlots.length,
                itemBuilder: (context, index) {
                  var date = model.visibleDateSlots[index];

                  return CalendarDateSquareWidget(
                    date: date,
                    selected: date == model.selectedDate,
                    didSelectDate: callback.onSelectDate,
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 16.dp),
        Expanded(
          child: SingleChildScrollView(
            controller: callback.timeController,
            child: Column(
              children: [
                TimeslotListWidget(
                  model: model,
                  onSelectTime: callback.onSelectTime,
                  timeController: callback.timeController,
                ),
                Container(
                  height: footerHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Footer(
                    model,
                    onSubmitSelectedTime: callback.onSubmitSelectedTime,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  double get footerHeight {
    return model.selectedTime != null
        ? 253.dp
        : 173.dp;
  }

}




