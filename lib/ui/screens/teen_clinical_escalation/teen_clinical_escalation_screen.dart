import 'dart:async';

import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/common_widgets/full_screen_progress_indicator.dart';
import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:mini_ginger_web/view_models/fusion_teen_clinical_escalation_model.dart';

class TeenClinicalEscalationScreen extends StatefulWidget {
  final FusionTeenClinicalEscalationModel model;

  const TeenClinicalEscalationScreen({this.model, Key key}) : super(key: key);

  @override
  State<TeenClinicalEscalationScreen> createState() =>
      _TeenClinicalEscalationScreenState();
}

class _TeenClinicalEscalationScreenState
    extends State<TeenClinicalEscalationScreen> {
  MetricsProvider metrics;
  FusionTeenClinicalEscalationModel model;

  @override
  void initState() {
    model = widget.model ?? FusionTeenClinicalEscalationModel();
    unawaited(model.listenToServiceEvents());
    unawaited(model.loadState());
    metrics = serviceLocator.get<MetricsProvider>();
    metrics.track(TeenClinicalEscalationViewed());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GingerCorePalette.transparent,
      body: SafeArea(
        child: ModelProvider<FusionTeenClinicalEscalationModel>(
          model: model,
          child: ModelBuilder<FusionTeenClinicalEscalationModel>(
            builder: (context, model, child) {
              List<Widget> children = [];
              children.add(FullScreenProgressIndicator());

              return Stack(
                children: children,
              );
            },
          ),
        ),
      ),
    );
  }
}
