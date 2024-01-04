import 'dart:math';

import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/shared/global_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/commons/ginger_core_palette.dart';
import 'package:mini_ginger_web/commons/theme.dart';
import 'package:mini_ginger_web/dependency/dependency_manager.dart';
import 'package:mini_ginger_web/navigation/app_routes.dart';
import 'package:mini_ginger_web/ui/screens/ginger_splash.dart';
import 'package:mini_ginger_web/view_models/app_model.dart';
import 'package:provider/provider.dart';

import 'view_models/base_model.dart';

class MainApp extends StatefulWidget {
  final DependencyManager dependencyManager;

  const MainApp(this.dependencyManager, {Key key})
      : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final logger = Logger("MainApp");
  MainAppModel appModel;
  bool dependencyLoaded = false;

  @override
  void initState() {
    _initDependencies();
    super.initState();
  }

  @override
  void dispose() {
    appModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!dependencyLoaded) {
      return MaterialApp(
        localizationsDelegates: const [
          R.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: R.delegate.supportedLocales,
        locale: const Locale('en'),
        localeResolutionCallback: (locale, supportedLocales) {
          if (R.delegate.isSupported(locale)) {
            return locale;
          }

          return const Locale.fromSubtags(languageCode: 'en');
        },
        theme: WebAppTheme.light(),
        darkTheme: WebAppTheme.dark(),
        color: GingerCorePalette.white,
          home: const GingerSplash(),
      );
    }

    return MultiProvider(
      providers: [ModelProvider<MainAppModel>(model: appModel)],
      child: ModelBuilder<MainAppModel>(
        builder: (context, model, child) {
          var preferredLocale = Locale.fromSubtags(
              languageCode: widget.dependencyManager.preferredLanguage);
          return MaterialApp(
            builder: (context, child) {
              final mQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mQuery.copyWith(
                  textScaleFactor: min(mQuery.textScaleFactor, 1.4),
                ),
                child: child,
              );
            },

            navigatorKey: NavigatorKeys.rootNavigatorKey,
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: WillPopScope(
                onWillPop: () async {
                  return !(await NavigatorKeys.appNavigatorKey.currentState
                      ?.maybePop() ??
                      false);
                },
                child: Navigator(
                  key: NavigatorKeys.appNavigatorKey,
                  initialRoute: AppRoutes.start,
                  onGenerateRoute: AppRoutes.getRoute,
                  onUnknownRoute: (RouteSettings settings) {
                    return MaterialPageRoute<void>(
                      settings: settings,
                      builder: (BuildContext context) {
                        Navigator.pop(context);
                        return Container();
                      },
                    );
                  },
                ),
              ),
            ),
            localizationsDelegates: const [
              R.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: R.delegate.supportedLocales,
            locale: preferredLocale,
            localeResolutionCallback: (locale, supportedLocales) {
              if (R.delegate.isSupported(locale)) {
                return locale;
              }

              return const Locale.fromSubtags(languageCode: 'en');
            },
            theme: WebAppTheme.light(),
            darkTheme: WebAppTheme.dark(),
            title: "Headspace Care Coaching Scheduler",
          );
        },
      ),
    );
  }


  Future<void> _initDependencies() async {
    await widget.dependencyManager.init().then((_) {
      appModel = MainAppModel();

      setState(() {
        dependencyLoaded = true;
      });

      logger.fine('App loaded');
      var m = serviceLocator.get<MetricsProvider>();
      m.track(OpenedAppEvent());
    }).catchError((e) {
        logger.severe('Error while loading dependencies: ${e.toString()}');
      });
  }

  /// This method is responsible for ensuring that all child widgets that are
  /// currently mounted in the app are marked for rebuild when we are in an app
  /// language change scenario.
  void rebuildAllChildren(BuildContext context) {
    // Reset flag immediately
    appModel.clearChildWidgetsRebuildFlag();

    // Mark 'needs build' on all app's child widgets.
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }
}


