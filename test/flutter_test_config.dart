import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:mini_ginger_web/commons/theme.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      theme: WebAppTheme.light(),
      platformGoldensConfig: PlatformGoldensConfig(
        platforms: {HostPlatform.macOS},
        enabled: HostPlatform.current().isMacOS,
        theme: WebAppTheme.light(),
      ),
      ciGoldensConfig: const CiGoldensConfig(
        enabled: false,
      )
    ),
    run: testMain,
  );
}