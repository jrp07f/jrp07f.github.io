import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_typography.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/coaching_scheduler_screen.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/components/timeslot_list_widget.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/components/footer.dart';
import 'package:mini_ginger_web/ui/widgets/header.dart';
import 'package:mini_ginger_web/ui/widgets/calendar_date_square_widget.dart';
import 'package:mini_ginger_web/ui/widgets/carousel_control.dart';
import 'package:mini_ginger_web/ui/widgets/header_title.dart';
import 'package:mini_ginger_web/ui/widgets/linear_progress_bar.dart';
import 'package:mini_ginger_web/view_models/scheduler_model.dart';

class TabletCoachingSchedulerScreen extends StatelessWidget {
  final SchedulerModel model;
  final CoachingSchedulerScreenCallback callback;

  const TabletCoachingSchedulerScreen(this.model, {
    @required this.callback,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60.dp,
          child: Header(
            companyName: model.companyName,
            companyImageUrl: model.companyImageUrl,
          ),
        ),
        SizedBox(
          width: 554.dp,
          child: Column(
            children: [
              SizedBox(height: 32.dp),
              SizedBox(
                width: 320.dp,
                child: const LinearProgressBar(percent: 0.85),
              ),
              SizedBox(height: 32.dp),
              HeaderTitle(text: R.current.coaching_scheduler_title),
              SizedBox(height: 24.dp),
              Text(
                R.current.coaching_scheduler_subtitle,
                style: DesktopGingerTypography()
                    .desktopBodyMedium
                    .copyWith(color: HeadspacePalette.lightModeTextWeak),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.dp),
            ],
          ),
        ),
        SizedBox(
          height: 100.dp,
          child: SizedBox(
            width: carouselWidth,
            child: NotificationListener<ScrollNotification>(
              onNotification: callback.onDateScroll,
              child: Semantics(
                label: R.current.semantics_date_selector_slider_label,
                child: CarouselControl(
                  scrollController: callback.dateController,
                  showDarkControls: true,
                  parentContext: context,
                  spacingOffset: 100,
                  controlVerticalPosition: 30.dp,
                  controlSize: 40.dp,
                  child: ListView.builder(
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
          ),
        ),
        const SizedBox(height: 25.0),
        Expanded(
          child: SizedBox(
            width: carouselWidth,
            child: TimeslotListWidget(
              model: model,
              onSelectTime: callback.onSelectTime,
              timeController: callback.timeController,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          color: HeadspacePalette.lightModeBorder,
          height: 2.dp,
          width: double.infinity,
        ),
        Container(
          height: 104.dp,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Footer(
            model,
            onSubmitSelectedTime: callback.onSubmitSelectedTime,
          ),
        ),
      ],
    );
  }

  double get carouselWidth {
    return 99.dp * 5 + 16.dp * 4;
  }

}

