import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/ui/screens/add_card/add_card_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../device.dart';
import '../../golden_test_device_scenario.dart';
import '../../mocks.dart';
import '../../test_dependency_manager.dart';
import '../../widget_test_util.dart';

void main() async {
  var devices = [
    Device.smallPhone,
    Device.iphone11,
    Device.tabletPortrait,
    Device.tabletLandscape,
  ];

  var languageCodes = [
    'en',
    'es',
    'fr',
  ];

  for (var languageCode in languageCodes) {
    var locale = Locale(languageCode);
    group(languageCode, () {
      setUp(() async {
        var launchUrl = Uri.parse(
            'http://localhost:63634/teen-clinical-escalation?workflow_hash=12314');
        var dependencyManager = TestDependencyManager(
          launchUrl: launchUrl,
          locale: locale,
          isGoldenTest: true,
        );
        await dependencyManager.init();
      });

      for (var device in devices) {
        var model = AddCardModelMock();

        goldenTest(
          'renders ${device.name} $languageCode correctly',
          builder: () {
            /// GIVEN
            when(() => model.busy).thenReturn(false);
            when(() => model.shouldDisableButton).thenReturn(true);

            return GoldenTestGroup(
              children: [
                GoldenTestDeviceScenario(
                  name: 'AddCardScreen',
                  device: device,
                  builder: () {
                    return AddCardScreen(model: model);
                  },
                ),
              ],
            );
          },
          fileName: '${device.name} $languageCode AddCardScreen',
          pumpWidget: (tester, widget) async {
            await tester.pumpWidget(
              WidgetTestUtil.wrapWidgetWithMaterialApp(
                widget: widget,
                selectedLocale: locale,
                isGoldenTest: true,
              ),
            );
          },
          pumpBeforeTest: (tester) async {
            await tester.pumpAndSettle();
            await precacheImages(tester);
          },
          skip: !AlchemistConfig.current().platformGoldensConfig.enabled,
        );
      }
    });
  }
}
