
import 'package:mini_ginger_web/services/platform/platform_service.dart';
import 'package:mini_ginger_web/services/platform/js_binding.dart'
  if (dart.library.js) 'package:mini_ginger_web/services/platform/js_bindings_impl.dart';

class WebPlatformService implements PlatformService {
  JSBindings _bindings;

  WebPlatformService([this._bindings]) {
    _bindings ??= JSBindings();
  }

  @override
  Future<String> getDeviceTimezone() {
    return Future.value(_bindings.getDeviceTimeZone());
  }
}
