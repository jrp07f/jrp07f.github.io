import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_typography.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';

class Header extends StatelessWidget {
  const Header({
    Key key,
    @required this.companyName,
    @required this.companyImageUrl,
  }) : super(key: key);

  final String companyName;
  final String companyImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      // height: 59.dp,
      child: Row(
        children: [
          Container(
            height: 22.dp,
            width: 22.dp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: HeadspacePalette.orange,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.dp),
            height: 24.dp,
            width: 1,
            color: HeadspacePalette.borderStrong,
          ),
          companyImageUrl?.isNotEmpty ?? false
              ? Image.network(
                  companyImageUrl,
                  height: 22.dp,
                  excludeFromSemantics: true,
                )
              : const SizedBox(),
          const SizedBox(width: 8.0),
          Text(companyName,
              style: GingerTypography()
                  .hs_font_label_s
                  .copyWith(color: HeadspacePalette.lightModeTextWeaker)),
        ],
      ),
    );
  }
}