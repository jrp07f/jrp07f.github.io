import 'package:alchemist/alchemist.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/models/timeline_chart_item.dart';
import 'package:care_dart_sdk/utilities/enums/timeline_chart_item_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ginger_web/ui/screens/guardian_consent/guardian_consent_screen.dart';
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

  for(var languageCode in languageCodes) {
    var locale = Locale(languageCode);
    group(languageCode, () {

      setUp(() async {
        var launchUrl = Uri.parse(
            'http://localhost:63634/guardian-consent?workflow_hash=12314');
        var dependencyManager = TestDependencyManager(
          launchUrl: launchUrl,
          locale: locale,
          isGoldenTest: true,
        );
        await dependencyManager.init();
      });

      for(var device in devices) {
        var model = FusionGuardianConsentModelMock();

        goldenTest(
          'renders ${device.name} $languageCode consent status correctly',
          builder: () {
            /// GIVEN
            when(() => model.busy).thenReturn(false);

            return GoldenTestGroup(
              children: [
                GoldenTestDeviceScenario(
                  name: 'GuardianConsentScreen',
                  device: device,
                  builder: () {
                    return GuardianConsentScreen(model: model);
                  },
                ),
              ],
            );
          },
          fileName:
          '${device.name} $languageCode GuardianConsentScreen Consent Status',
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
            R.delegate.load(locale);
            when(() => model.firstItem).thenReturn(TimelineChartItem(
              title: R.current.guardian_consent_team_consent_workflow_title,
              subtitle: R.current.guardian_consent_team_consent_workflow_subtitle,
              state: TimelineChartItemState.inProgress,
              onTap: () {},
            ));
            when(() => model.secondItem).thenReturn(TimelineChartItem(
              title:
              R.current.guardian_consent_team_dependent_info_workflow_title,
              subtitle: R
                  .current.guardian_consent_team_dependent_info_workflow_subtitle,
              state: TimelineChartItemState.notStarted,
              onTap: null,
            ));

            await tester.pumpAndSettle();
            await precacheImages(tester);
          },
          skip: !AlchemistConfig.current().platformGoldensConfig.enabled,
        );

        goldenTest(
          'renders ${device.name} $languageCode declined status correctly',
          builder: () {
            /// GIVEN
            when(() => model.busy).thenReturn(false);

            return GoldenTestGroup(
              children: [
                GoldenTestDeviceScenario(
                  name: 'GuardianConsentScreen',
                  device: device,
                  builder: () {
                    return GuardianConsentScreen(model: model);
                  },
                ),
              ],
            );
          },
          fileName:
          '${device.name} $languageCode GuardianConsentScreen Declined Status',
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
            R.delegate.load(locale);
            when(() => model.firstItem).thenReturn(TimelineChartItem(
              title:
              R.current.guardian_consent_team_consent_workflow_title_rejected,
              subtitle: R.current
                  .guardian_consent_team_consent_workflow_subtitle_rejected,
              state: TimelineChartItemState.declined,
              onTap: () {},
            ));
            when(() => model.secondItem).thenReturn(TimelineChartItem(
              title:
              R.current.guardian_consent_team_dependent_info_workflow_title,
              subtitle: R
                  .current.guardian_consent_team_dependent_info_workflow_subtitle,
              state: TimelineChartItemState.notStarted,
              onTap: null,
            ));

            await tester.pumpAndSettle();
            await precacheImages(tester);
          },
          skip: !AlchemistConfig.current().platformGoldensConfig.enabled,
        );

        goldenTest(
          'renders ${device.name} $languageCode dependent_info status correctly',
          builder: () {
            /// GIVEN
            when(() => model.busy).thenReturn(false);

            return GoldenTestGroup(
              children: [
                GoldenTestDeviceScenario(
                  name: 'GuardianConsentScreen',
                  device: device,
                  builder: () {
                    return GuardianConsentScreen(model: model);
                  },
                ),
              ],
            );
          },
          fileName:
          '${device.name} $languageCode GuardianConsentScreen Dependent Info Status',
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
            R.delegate.load(locale);
            when(() => model.firstItem).thenReturn(TimelineChartItem(
              title: R.current.guardian_consent_team_consent_workflow_title,
              subtitle: R.current.guardian_consent_team_consent_workflow_subtitle,
              state: TimelineChartItemState.completed,
              onTap: null,
            ));
            when(() => model.secondItem).thenReturn(TimelineChartItem(
              title:
              R.current.guardian_consent_team_dependent_info_workflow_title,
              subtitle: R
                  .current.guardian_consent_team_dependent_info_workflow_subtitle,
              state: TimelineChartItemState.inProgress,
              onTap: () {},
            ));

            await tester.pumpAndSettle();
            await precacheImages(tester);
          },
          skip: !AlchemistConfig.current().platformGoldensConfig.enabled,
        );

        goldenTest(
          'renders ${device.name} $languageCode completed status correctly',
          builder: () {
            /// GIVEN
            when(() => model.busy).thenReturn(false);

            return GoldenTestGroup(
              children: [
                GoldenTestDeviceScenario(
                  name: 'GuardianConsentScreen',
                  device: device,
                  builder: () {
                    return GuardianConsentScreen(model: model);
                  },
                ),
              ],
            );
          },
          fileName:
          '${device.name} $languageCode GuardianConsentScreen Completed Status',
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
            R.delegate.load(locale);
            when(() => model.firstItem).thenReturn(TimelineChartItem(
              title: R.current.guardian_consent_team_consent_workflow_title,
              subtitle: R.current.guardian_consent_team_consent_workflow_subtitle,
              state: TimelineChartItemState.completed,
              onTap: null,
            ));
            when(() => model.secondItem).thenReturn(TimelineChartItem(
              title:
              R.current.guardian_consent_team_dependent_info_workflow_title,
              subtitle: R
                  .current.guardian_consent_team_dependent_info_workflow_subtitle,
              state: TimelineChartItemState.completed,
              onTap: null,
            ));

            await tester.pumpAndSettle();
            await precacheImages(tester);
          },
          skip: !AlchemistConfig.current().platformGoldensConfig.enabled,
        );
      }
    });
  }
}
