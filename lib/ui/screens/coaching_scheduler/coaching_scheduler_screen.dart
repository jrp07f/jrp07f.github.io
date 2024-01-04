import 'dart:async';

import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/services/config_provider.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/common_widgets/full_screen_progress_indicator.dart';
import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:care_dart_sdk/utilities/environment_config.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/models/scheduler_slots.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/components/desktop_coaching_scheduler_screen.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/components/mobile_coaching_scheduler_screen.dart';
import 'package:mini_ginger_web/ui/screens/coaching_scheduler/components/tablet_coaching_scheduler_screen.dart';
import 'package:mini_ginger_web/ui/widgets/network_error_retry_widget.dart';
import 'package:mini_ginger_web/ui/widgets/responsive_layout.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:mini_ginger_web/view_models/scheduler_model.dart';

class CoachingSchedulerScreen extends StatefulWidget {
  final SchedulerModel model;

  const CoachingSchedulerScreen({this.model, Key key}) : super(key: key);

  @override
  State<CoachingSchedulerScreen> createState() =>
      _CoachingSchedulerScreenState();
}

class _CoachingSchedulerScreenState extends State<CoachingSchedulerScreen> implements CoachingSchedulerScreenCallback {
  final config = serviceLocator.get<ConfigProvider>();
  final metrics = serviceLocator.get<MetricsProvider>();
  SchedulerModel model;

  ScrollController _dateController;
  ScrollController _timeController;

  @override
  void initState() {
    metrics.track(WebSchedulerViewed());

    _dateController = ScrollController();
    _timeController = ScrollController();
    model = widget.model ?? SchedulerModel();

    model.load();
    super.initState();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GingerCorePalette.white,
      body: SafeArea(
        child: ModelProvider<SchedulerModel>(
          model: model,
          child: ModelBuilder<SchedulerModel>(
            builder: (context, model, child) {
              List<Widget> children = [];

              if(model.shouldPresentErrorState) {
                children.add(_buildErrorLayout(model.error));
              } else if (model.hasAvailability){
                children.add(
                  ResponsiveLayout(
                    mobile: MobileCoachingSchedulerScreen(
                      model,
                      callback: this,
                    ),
                    tablet: TabletCoachingSchedulerScreen(
                      model,
                      callback: this,
                    ),
                    desktop: DesktopCoachingSchedulerScreen(
                      model,
                      callback: this,
                    )
                  ),
                );
              }

              if (model.busy) {
                children.add(FullScreenProgressIndicator());
              }

              return Stack(
                children: children,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorLayout(String message) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(
        top: 100.dp,
        left: 63.dp,
        right: 63.dp,
      ),
      child: NetworkErrorRetryWidget(
        key: const Key('ErrorViewWidget'),
        message: message,
        onTap: model.load,
      ),
    );
  }

  @override
  void onSelectDate(SchedulerDate dateSlot) {
    if (model.selectedDate == dateSlot) return;
    model.actionSelectDate(dateSlot);

    _scrollTimePosition();
  }

  @override
  void onSelectTime(SchedulerTime timeSlot, {bool scrollToFooter = false}) {
    if (timeSlot != null && model.selectedTime != timeSlot) {
      if(scrollToFooter) {
        _scrollToFooter();
      }
    }
    model.actionSelectTime(timeSlot);
  }

  void _scrollTimePosition() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _timeController.animateTo(model.timeScrollPosition,
            duration: const Duration(milliseconds: 400), curve: Curves.ease);
      }
    });
  }

  void _scrollToFooter() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _timeController.animateTo(_timeController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400), curve: Curves.ease);
      }
    });
  }

  @override
  bool onDateScroll(ScrollNotification scrollNotification) {
    if (scrollNotification is ScrollEndNotification) model.actionDateScrolled();

    return true;
  }

  @override
  bool onTimeScroll(ScrollNotification scrollNotification) {
    if (scrollNotification is ScrollEndNotification) model.actionTimeScrolled();

    return true;
  }

  @override
  void onSubmitSelectedTime() {
    model.actionSubmitSelectedTime();
    /// Pause audio if playing when time has been selected
    if(Environment.current.type != EnvironmentType.TEST) {
      var audio = serviceLocator.get<AudioPlayer>();
      if (audio?.playing ?? false) {
        audio.pause();
        metrics.track(FeelingOverwhelmedAudioStopped());
      }
    }
  }

  @override
  ScrollController get dateController => _dateController;

  @override
  ScrollController get timeController => _timeController;
}

abstract class CoachingSchedulerScreenCallback {
  void onSelectDate(SchedulerDate dateSlot);
  void onSelectTime(SchedulerTime timeSlot, {bool scrollToFooter = false});
  bool onDateScroll(ScrollNotification scrollNotification);
  bool onTimeScroll(ScrollNotification scrollNotification);
  void onSubmitSelectedTime();

  ScrollController get dateController;
  ScrollController get timeController;
}