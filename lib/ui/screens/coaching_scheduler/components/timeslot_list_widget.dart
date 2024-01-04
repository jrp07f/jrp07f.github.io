import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:care_dart_sdk/ui/common_widgets/bordered_radio_list_item.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:mini_ginger_web/models/scheduler_slots.dart';
import 'package:mini_ginger_web/ui/widgets/responsive_layout.dart';
import 'package:mini_ginger_web/view_models/scheduler_model.dart';

class TimeslotListWidget extends StatelessWidget {
  const TimeslotListWidget({
    Key key,
    @required this.model,
    @required this.onSelectTime,
    @required this.timeController,
  }) : super(key: key);

  final SchedulerModel model;
  final void Function(SchedulerTime timeSlot, {bool scrollToFooter}) onSelectTime;
  final ScrollController timeController;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: shrinkWrappedList(),
      tablet: list(
        const BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      desktop: list(BorderRadius.circular(10.0)),
    );
  }

  Widget shrinkWrappedList() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 24.dp,
        horizontal: 24.0,
      ),
      child: ListView.builder(
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: model.visibleTimeSlots.length,
        itemBuilder: (context, index) {
          if (index >= model.visibleTimeSlots.length) {
            return const SizedBox();
          }

          var time = model.visibleTimeSlots[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12.dp),
            child: BorderedRadioListItem(
              title: model.getSlotTitle(time),
              onTap: () {
                onSelectTime(time, scrollToFooter: true);
              },
              checked: time == model.selectedTime,
              maxLines: 1,
            ),
          );
        },
      ),
    );
  }

  Widget list(BorderRadius borderRadius) {
    return Container(
      padding: EdgeInsets.only(
        top: 32.dp,
        left: 56.0,
        right: 20.0,
        bottom: 32.dp,
      ),
      child: Scrollbar(
        controller: timeController,
        thumbVisibility: true,
        radius: const Radius.circular(30.0),
        child: ListView.builder(
          primary: false,
          controller: timeController,
          itemCount: model.visibleTimeSlots.length,
          itemBuilder: (context, index) {
            if (index >= model.visibleTimeSlots.length) {
              return const SizedBox();
            }

            var time = model.visibleTimeSlots[index];
            return Container(
              margin: EdgeInsets.only(
                bottom: 12.dp,
                right: 36.0,
              ),
              child: BorderedRadioListItem(
                title: model.getSlotTitle(time),
                onTap: () {
                  onSelectTime(time, scrollToFooter: false);
                },
                checked: time == model.selectedTime,
                maxLines: 1,
              ),
            );
          },
        ),
      ),
    );
  }
}
