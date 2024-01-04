
/// Stub class for other platforms. This class is NEVER used at runtime, it is
/// only required for import issues introduced by JS interop.
class JSBindings {
  String getDeviceTimeZone() {
    return 'America/Los Angeles';
  }
}
