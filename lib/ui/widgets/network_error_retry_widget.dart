import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/ui/controls/primary_button.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:care_dart_sdk/generated/l10n.dart';

class NetworkErrorRetryWidget extends StatelessWidget {
  final String message;
  final Function onTap;

  const NetworkErrorRetryWidget({Key key, @required this.message, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      onTap: onTap,
      hint: R.current.semantics_double_tap_to_retry,
      excludeSemantics: true,
      child: Column(
        children: [
          Image.asset(
            'assets/wifiSlash.webp',
            height: 88,
            width: 88,
            excludeFromSemantics: true,
          ),
          SizedBox(height: 38.dp),
          Text(
            message,
            style: GingerTypography().hs_font_body_m,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.dp),
          PrimaryButton.medium(
            title: R.current.retry,
            onTap: onTap,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}
