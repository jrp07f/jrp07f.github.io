import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_ginger_web/ui/screens/ginger_splash.dart';
import 'package:mini_ginger_web/view_models/app_model.dart';
import 'package:mini_ginger_web/view_models/base_model.dart';

class GingerLaunchScreen extends StatefulWidget {
  const GingerLaunchScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GingerLaunchScreenState();
  }
}

class _GingerLaunchScreenState extends State<GingerLaunchScreen> {
  MainAppModel appModel;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      appModel.continueLaunch();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// When the app launches, this is the first place where a mediaQuery is available.
    /// So we set the deviceHeight for text scaling here.
    DeviceScale().currentDeviceHeight = MediaQuery.of(context).size.height;

    // Set app model's navigator now that it is available.
    appModel = ModelProvider.of<MainAppModel>(context, listen: false);
    appModel.navigator = Navigator.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return const GingerSplash();
  }
}
