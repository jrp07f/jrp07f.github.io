import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/controls/primary_button.dart';
import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:care_dart_sdk/utilities/launch_util.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:care_dart_sdk/generated/l10n.dart';

class ErrorScreen extends StatefulWidget {
  final String title;
  final String body;
  final String imagePath;

  const ErrorScreen({
    Key key,
    this.title,
    this.body,
    this.imagePath,
  }) : super(key: key);

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  MetricsProvider metrics;

  @override
  void initState() {
    metrics = serviceLocator.get<MetricsProvider>();
    metrics.track(ErrorViewed());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 240.0.dp,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              titleSpacing: 0.0,
              elevation: 0,
              centerTitle: false,
              leading: null,
              backgroundColor: GingerCorePalette.white,
              title: const SizedBox(width: 36.0),
              flexibleSpace: FlexibleSpaceBar(
                background: Align(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0.dp),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32.0),
                      child: Image.asset(
                        widget.imagePath ?? 'assets/link_error_header.webp',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: Container(
            color: GingerCorePalette.white,
            padding: EdgeInsets.only(top: 12.0.dp),
            child: Stack(
              children: [
                ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    bottom: 100.0.dp,
                    left: 24.dp,
                    right: 24.dp,
                  ),
                  children: [
                    Text(
                      widget.title ?? R.current.link_error_title,
                      style: GingerTypography().hs_font_heading_l,
                    ),
                    Text(
                      widget.body ?? R.current.link_error_body,
                      style: GingerTypography().hs_font_body_m,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 96.0.dp,
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 24.0.dp,
                            right: 24.0.dp,
                            bottom: 10.0.dp,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _mainCTAButton(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainCTAButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 48.0,
      child: PrimaryButton.medium(
        key: const Key('MainCTAButton'),
        title: R.current.done,
        isFullWidth: true,
        onTap: onDoneTapped,
      ),
    );
  }

  void onDoneTapped() {
    metrics.track(ErrorCtaTapped());
    var deviceLaunchUtil = serviceLocator.get<DeviceLaunchUtil>();
    deviceLaunchUtil.launch('https://www.headspace.com');
  }
}
