import 'dart:async';

import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/services/config_provider.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/navigators/navigation_router.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Full screen view models should extend this class to incorporate navigation
/// features.
///
/// This class facilitates 2 main features:
/// - navigation can be mocked and tested easily in unit test.
/// - models can handle navigation directly without a notify/redraw.
///
/// The corresponding widget must do the following to configure navigation.
/// - override didChangeDependencies, adding the following statement:
///   - model.navigator = Navigator.of(context);
class NavigationModel extends ContextModel {
  NavigationRouter _router;

  set router(NavigationRouter router) {_router = router;}
  NavigationRouter get router => _router ?? NavigationRouter(Navigator.of(context));

  NavigatorState get navigator => _router?.navigator;

  bool busy = false;

  set navigator(NavigatorState n) {
    if (_router == null) {
      _router = NavigationRouter(n);
      return;
    }
    _router.navigator = n;
  }
}

class DebouncedChangeNotifier extends ChangeNotifier {
  int _currentTaskVersion = 0;
  int _taskVersion = 0;

  /// Handle multiple changes by versioning the microTask.
  @override
  void notifyListeners() {
    if (_taskVersion == _currentTaskVersion) {
      _taskVersion++;
      scheduleMicrotask(() {
        _currentTaskVersion++;
        _taskVersion = _currentTaskVersion;

        if (!hasListeners) return;
        super.notifyListeners();
      });
    }
  }
}

/// Contains common model components easy for testing:
/// - enables platform specific behavior testing easier.
class ContextModel extends DebouncedChangeNotifier {
  BuildContext context;

  MetricsProvider metricsProvider = serviceLocator.get<MetricsProvider>() ??
      EmptyMetricsProvider();
  ConfigProvider config = serviceLocator.get<ConfigProvider>() ??
      LocalConfig();
}

class ModelProvider<T extends ContextModel> extends ChangeNotifierProvider<T> {
  final T model;

  ModelProvider({Key key, @required this.model, child})
      : super.value(key: key, value: model, child: child);

  @override
  Widget build(BuildContext context) {
    model.context = context;
    return super.build(context);
  }

  static M of<M extends ContextModel>(
      BuildContext context, {
        bool listen = false,
      }) {
    M model = Provider.of<M>(context, listen: listen);
    model.context = context;
    return model;
  }

}

class ModelBuilder<T extends ContextModel>
    extends Consumer<T> {
  final bool listen;
  final Widget child;

  ModelBuilder({Key key,
    Function(BuildContext context, T value, Widget child) builder,
    this.child,
    this.listen = true,
  }) : super(key: key,
    builder: builder,
    child: child,
  );

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    var model = Provider.of<T>(context);
    model.context = context;
    return builder(
      context,
      model,
      child,
    );
  }
}
