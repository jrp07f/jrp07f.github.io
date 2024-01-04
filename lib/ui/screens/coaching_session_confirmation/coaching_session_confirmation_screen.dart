import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/utilities/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/commons/ginger_core_palette.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/desktop_coaching_session_confirmation_screen.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/mobile_coaching_session_confirmation_screen.dart';
import 'package:mini_ginger_web/ui/screens/coaching_session_confirmation/components/tablet_coaching_session_confirmation_screen.dart';
import 'package:mini_ginger_web/ui/widgets/full_screen_progress_indicator.dart';
import 'package:mini_ginger_web/ui/widgets/responsive_layout.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';
import 'package:mini_ginger_web/view_models/coaching_session_confirmation_model.dart';

class CoachingSessionConfirmationScreen extends StatefulWidget {
  final CoachingSessionConfirmationModel model;
  final DateTime scheduledTime;

  const CoachingSessionConfirmationScreen(
    this.scheduledTime, {
    this.model,
    Key key,
  }) : super(key: key);

  @override
  State<CoachingSessionConfirmationScreen> createState() =>
      _CoachingSessionConfirmationScreenState();
}

class _CoachingSessionConfirmationScreenState
    extends State<CoachingSessionConfirmationScreen>
    implements CoachingSessionConfirmationScreenCallback {
  final metrics = serviceLocator.get<MetricsProvider>();
  CoachingSessionConfirmationModel model;

  @override
  void initState() {
    metrics.track(CoachingSessionConfirmationViewedEvent());
    model = widget.model ?? CoachingSessionConfirmationModel();
    model.scheduledTime = widget.scheduledTime;

    model.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GingerCorePalette.white,
      body: ModelProvider<CoachingSessionConfirmationModel>(
        model: model,
        child: ModelBuilder<CoachingSessionConfirmationModel>(
            builder: (context, model, child) {
          List<Widget> children = [];

          children.add(
            ResponsiveLayout(
              mobile: MobileCoachingSessionConfirmationScreen(
                model,
                callback: this,
              ),
              tablet: TabletCoachingSessionConfirmationScreen(
                model,
                callback: this,
              ),
              desktop: DesktopCoachingSessionConfirmationScreen(
                model,
                callback: this,
              ),
            ),

          );

          if (model.busy) {
            children.add(const FullScreenProgressIndicator());
          }

          return Stack(
            children: children,
          );
        }),
      ),
    );
  }

  @override
  void onSubmitTapped() {
    model.actionSubmit();
  }

  @override
  void onEapCtaTapped() {
    model.redirectToHeadspaceHub();
  }

  @override
  String get submitText {
    return model.memberType == 'D2C'
        ? R.current.continue_
        : R.current.coaching_session_confirmation_cta;
  }

  @override
  String get headerAssetPath {
    return model.memberType == 'D2C' || model.enrollmentFlow == 'fusion'
        ? 'assets/coachingSessionConfirmed.webp'
        : 'assets/umdCoachingSessionConfirmed.webp';
  }

  @override
  String get talkSoonMessage {
    if (StringUtils.isNotEmpty(model.username)) {
      return R.current.talk_soon_username(model.username);
    }

    return R.current.talk_soon_only;
  }
}

abstract class CoachingSessionConfirmationScreenCallback {
  String get submitText;

  String get headerAssetPath;

  String get talkSoonMessage;

  void onSubmitTapped();
  void onEapCtaTapped();
}
