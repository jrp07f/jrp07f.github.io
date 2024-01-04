import 'package:care_dart_sdk/ui/controls/primary_button.dart';
import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_typography.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/ui/widgets/audio_widget.dart';
import 'package:mini_ginger_web/ui/widgets/responsive_layout.dart';
import 'package:care_dart_sdk/utilities/date_utils.dart' as app_date;
import 'package:mini_ginger_web/view_models/scheduler_model.dart';

class Footer extends StatelessWidget {
  const Footer(
    this.model, {
    Key key,
    @required this.onSubmitSelectedTime,
  }) : super(key: key);

  final SchedulerModel model;
  final VoidCallback onSubmitSelectedTime;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: narrowFooter(),
      tablet: wideFooter(),
      desktop: wideFooter(),
    );
  }

  Widget narrowFooter() {
    return Column(
      children: [
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: Text(
            R.current.need_help_now,
            textAlign: TextAlign.center,
            style: DesktopGingerTypography()
                .desktopLabelSmall
                .copyWith(color: HeadspacePalette.lightModeText),
          ),
        ),
        SizedBox(height: 12.dp),
        const AudioWidget(),
        model.selectedTime != null
            ? Container(
                padding:
                    EdgeInsets.symmetric(vertical: 32.dp),
                child: PrimaryButton.medium(
                  color: GingerCorePalette.warmGrey700,
                  title: R.current.scheduler_book_action(
                    model.selectedTime.dayOfWeek,
                    model.selectedTime.timeOfDay,
                  ),
                  semanticLabel: R.current.scheduler_book_action(
                    app_date.DateUtils.formatFullWeekday(
                        model.selectedDate.localDateTime),
                    model.selectedTime.timeOfDay,
                  ),
                  onTap: onSubmitSelectedTime,
                ),
              )
            : SizedBox(height: 32.dp),
      ],
    );
  }

  Widget wideFooter() {
    return Row(
      children: [
        Text(
          R.current.need_help_now,
          textAlign: TextAlign.center,
          style: DesktopGingerTypography()
              .desktopLabelSmall
              .copyWith(color: HeadspacePalette.lightModeText),
        ),
        const SizedBox(width: 16.0),
        const SizedBox(
          width: 240.0,
          child: AudioWidget(),
        ),
        const Spacer(),
        model.selectedTime != null
            ? PrimaryButton.medium(
                color: GingerCorePalette.warmGrey700,
                title: R.current.scheduler_book_action(
                  model.selectedTime.dayOfWeek,
                  model.selectedTime.timeOfDay,
                ),
                semanticLabel: R.current.scheduler_book_action(
                  app_date.DateUtils.formatFullWeekday(
                      model.selectedDate.localDateTime),
                  model.selectedTime.timeOfDay,
                ),
                onTap: onSubmitSelectedTime,
                inline: true,
                isFullWidth: false,
              )
            : const Spacer(),
      ],
    );
  }
}
