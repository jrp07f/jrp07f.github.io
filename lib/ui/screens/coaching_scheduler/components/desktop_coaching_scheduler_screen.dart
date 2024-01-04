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

class DesktopCoachingSchedulerScreen extends StatelessWidget {
  final SchedulerModel model;
  final CoachingSchedulerScreenCallback callback;

  const DesktopCoachingSchedulerScreen(
    this.model, {
    @required this.callback,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 116.dp,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                height: 82.0.dp,
                child: Header(
                  companyName: model.companyName,
                  companyImageUrl: model.companyImageUrl,
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 680.0.dp,
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(top: 144.0.dp),
                        width: 320.dp,
                        child: Column(
                          children: [
                            const LinearProgressBar(percent: 0.85),
                            SizedBox(height: 24.0.dp),
                            HeaderTitle(text: R.current.coaching_scheduler_title),
                            SizedBox(height: 24.0.dp),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                R.current.coaching_scheduler_subtitle,
                                style: DesktopGingerTypography()
                                    .desktopBodyLarge
                                    .copyWith(color: HeadspacePalette.lightModeTextWeak),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 96.0.dp,
                            margin: const EdgeInsets.only(right: 32.0),
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
                                    controlSize: 36.0.dp,
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
                          const SizedBox(height: 24.0),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 32.0),
                              width: carouselWidth,
                              child: TimeslotListWidget(
                                model: model,
                                onSelectTime: callback.onSelectTime,
                                timeController: callback.timeController,
                              ),
                            ),
                          ),
                          const SizedBox(height: 60.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                color: HeadspacePalette.lightModeBorder,
                height: 2.0.dp,
                width: double.infinity,
              ),
              Container(
                height: 114.0.dp,
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Footer(
                  model,
                  onSubmitSelectedTime: callback.onSubmitSelectedTime,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double get carouselWidth {
    return 90.0.dp * 5 + 24.0.dp * 4;
  }
}