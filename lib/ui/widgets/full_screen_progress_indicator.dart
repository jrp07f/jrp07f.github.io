import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_ginger_web/commons/ginger_core_palette.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/ui/widgets/progress_indicator.dart';

class FullScreenProgressIndicator extends StatefulWidget {
  final double radius;
  final String semanticPresentationMessage;
  final String semanticDismissalMessage;

  const FullScreenProgressIndicator({
    this.radius = 12.0,
    this.semanticDismissalMessage,
    this.semanticPresentationMessage}) : super(key: const Key('FullScreenProgressIndicator'));

  @override
  _FullScreenProgressIndicatorState createState() => _FullScreenProgressIndicatorState();
}

class _FullScreenProgressIndicatorState extends State<FullScreenProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      excludeSemantics: true,
      explicitChildNodes: true,
      label: widget.semanticPresentationMessage ?? R.current.semantics_processing,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: GingerCorePalette.black.withOpacity(0.07),
        child: Center(
          child: PlatformActivityIndicator(radius: widget.radius,),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SemanticsService.announce(
      widget.semanticDismissalMessage ?? R.current.done,
      TextDirection.ltr,
    );

    super.dispose();
  }
}
