import 'dart:html';

class WebPersistence {
  final Storage _localStorage = window.localStorage;

  bool containsKey(Object key) {
    return _localStorage.containsKey(key);
  }

  String remove(Object key) {
    return _localStorage.remove(key);
  }

  void clear() {
    _localStorage.clear();
  }

  String operator [](Object key) {
    return _localStorage[key];
  }

  Iterable<MapEntry> get entries {
    return _localStorage.entries;
  }

  void operator []=(String key, String value) {
    _localStorage[key] = value;
  }
}
