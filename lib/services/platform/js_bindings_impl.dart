
@JS()
library bindings;

import 'package:js/js.dart';



/// Interfaces to declared Javascript methods/properties. This class might do
/// extra processing of converting between data types/constructs, e.g. from a
/// callback-based Javascript API to Dart Future or from a Dart map/object to a
/// Javascript object.
class JSBindings {
  static final JSBindings _instance = JSBindings._internal();

  JSBindings._internal();

  factory JSBindings() {
    return _instance;
  }

  String getDeviceTimeZone() {
    return _jsDateTimeFormat().resolvedOptions().timeZone;
  }

}

@JS('Intl.DateTimeFormat')
external _JSDateTimeFormat _jsDateTimeFormat();

@JS()
abstract class _JSDateTimeFormat {
  external _JSResolvedOptions resolvedOptions();
}

@JS()
abstract class _JSResolvedOptions {
  external String get timeZone;
}

// Start of Web Utils //
@JS('JSON.stringify')
external String stringify(Object obj);

// End of Web Utils //