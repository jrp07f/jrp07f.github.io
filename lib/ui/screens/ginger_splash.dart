import 'package:care_dart_sdk/ui/common_widgets/full_screen_progress_indicator.dart';
import 'package:care_dart_sdk/ui/shared/ginger_core_palette.dart';
import 'package:flutter/material.dart';

class GingerSplash extends StatelessWidget{
  const GingerSplash({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GingerCorePalette.white,
      body: Stack(
        children: <Widget>[
          FullScreenProgressIndicator(),
        ],
      ),
    );
  }

}