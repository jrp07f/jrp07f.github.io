import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:care_dart_sdk/utilities/environment_config.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_typography.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/view_models/coaching_session_confirmation_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ScanQrWidget extends StatelessWidget {
  const ScanQrWidget({
    Key key,
    @required this.model,
    this.onSubmitTapped,
  }) : super(key: key);

  final CoachingSessionConfirmationModel model;
  final VoidCallback onSubmitTapped;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24.dp),
        Container(
          color: HeadspacePalette.lightModeBorder,
          height: 2.dp,
          width: double.infinity,
        ),
        SizedBox(height: 24.dp),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    R.current.qr_code_download_instructions,
                    style: DesktopGingerTypography().desktopLabelMedium.copyWith(
                          color: HeadspacePalette.lightModeText,
                        ),
                  ),
                  SizedBox(height: 8.dp),
                  model.email != null
                      ? Text(
                          R.current.coaching_session_confirmation_instructions(
                              model.email),
                          style:
                              DesktopGingerTypography().desktopBody2xs.copyWith(
                                    color: HeadspacePalette.lightModeTextWeaker,
                                  ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            const SizedBox(width: 24.0),
            InkWell(
              key: const ValueKey('DownloadHeadspaceButton'),
              onTap: onSubmitTapped,
              child: Container(
                width: 135.dp,
                height: 135.dp,
                decoration: BoxDecoration(
                  color: HeadspacePalette.lightModeBackground,
                  border: Border.all(
                    color: const Color(0xFFDFDFDF),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Environment.current.type != EnvironmentType.TEST
                    ? QrImageView(
                        data: CoachingSessionConfirmationModel.hsAppStoreLink,
                      )
                    : SizedBox(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
