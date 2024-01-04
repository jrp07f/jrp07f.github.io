import 'package:mini_ginger_web/commons/serialization.dart';

/// ConfigProvider provides a standard interface for third party
/// feature flag and configuration services.
abstract class ConfigProvider {
  // Set the local default values used when remove values cannot be loaded.
  Future<void> setDefaults({Map<String, dynamic> defaults=defaultConfiguration});
  /// Fetch remote config values from the provider.
  /// Expiration prevents further remote fetches until the last fetch completes.
  /// Should be invoked whenever the application foregrounds.
  Future<void> fetch({Duration expiration=Duration.zero});
  double getDouble(String key);
  int getInt(String key);
  bool getBool(String key);
  String getString(String key);
  // Gets Map value from json encoded string value.
  Map<String, dynamic> getMap(String key);
  // Gets List value from json encoded string value.
  List getList(String key);
}

// LocalConfig pulls values from the static defaultConfiguration.
// This ConfigProvider is used in tests, debug and staging environments.
class LocalConfig implements ConfigProvider {

  Map <String, dynamic> defaults = {};

  @override
  Future<void> fetch({Duration expiration=Duration.zero}) {
    return Future.value(null);
  }

  @override
  double getDouble(String key) {
    return PreserveNull.asObject<double>(defaults[key]);
  }

  @override
  int getInt(String key) {
    return PreserveNull.asInt(defaults[key]);
  }

  @override
  bool getBool(String key) {
    return PreserveNull.asBool(defaults[key]);
  }

  @override
  List getList(String key) {
    return PreserveNull.jsonTo<List>(defaults[key]);
  }

  @override
  Map<String, dynamic> getMap(String key) {
    return PreserveNull.jsonTo<Map<String, dynamic>>(defaults[key]);
  }

  @override
  String getString(String key) {
    String value = defaults[key];
    if (value.contains("\\n")) {
      return value.replaceAll("\\n", "\n");
    } else {
      return value;
    }
  }

  @override
  Future<void> setDefaults({Map<String, dynamic> defaults=defaultConfiguration}) {
    this.defaults = defaults;
    return Future.value(null);
  }
}

// Defaults are configured here.
// All config keys should be added to this enum for simple autocompletion lookup.
class ConfigKeys {
  static const testMap = "testMap";
  static const testList = "testList";

  // Global default keys
  static const global_default_hotline = "global_default_hotline";
}

/// Provide default value for all supported values this is utilized by the
/// ConfigProvider as a fail-over when remote configuration cannot be loaded.
const Map<String, dynamic> defaultConfiguration = {

  /// These values are used for unit tests only.
  ConfigKeys.testMap: '{"foo":"bar"}',
  ConfigKeys.testList: '["foo","bar","bizz","buzz","bat"]',

  /// Actual values start here.
  // Global default values
  ConfigKeys.global_default_hotline: "988", // Default U.S. suicide hotline number
};
