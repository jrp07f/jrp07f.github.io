import 'dart:convert';

class JSON {
  static Map<String, dynamic> asMap(String responseBody) {
    return jsonDecode(responseBody);
  }

  static int valueAsInt(dynamic value, {String name="value"}) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.parse(value);
    throw ArgumentError.value(
        value, "value", "Value cannot be parsed as integer.");
  }

  static bool valueAsBool(dynamic value, {String name="value"}) {
    if (value == null) {
      throw ArgumentError.value(
          value, name, "Value cannot be parsed as boolean.");
    }
    if (value is bool) return value;
    if (value is int) return value == 0 ? false : true;
    if (value is double) value == 0 ? false : true;
    if (value is String) {
      return value == "" || value == "0" ? false : true;
    }
    throw ArgumentError.value(
        value, name, "Value cannot be parsed as boolean.");
  }

  static DateTime valueAsDateTime(dynamic value, {String name="value"}) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      if (value is String) return DateTime.parse(value);
    } on FormatException {
      throw ArgumentError.value(value, name, "Value cannot be parsed as DateTime.");
    }
    throw ArgumentError.value(value, name, "Value cannot be parsed as DateTime.");
  }
}

class PreserveNull {
  static DateTime intToDateTime(int i) => (i == null) ? null : DateTime.fromMillisecondsSinceEpoch(i);
  static bool intToBool(dynamic i) => (i == null) ? null : ((i == 1 || i == true) ? true : false);
  static int boolToInt(dynamic b) => (b == null) ? null : ((b == 1 || b) ? 1 : 0);
  static T jsonTo<T>(String t)  => (t == null) ? null : (jsonDecode(t) as T);
  static String toJson(dynamic o)  => (o == null) ? null : jsonEncode(o);
  static String asString(dynamic s) => (s == null) ? null : s.toString();
  static int asInt(dynamic i) => (i is int) ? i : (i is double) ? i.toInt() : (i is String) ? double.tryParse(i)?.toInt() : null;
  static double asDouble(dynamic i) => (i is double) ? i : (i is String) ? double.tryParse(i) : (i is int) ? i.toDouble() : null;
  static bool asBool(dynamic i) => i is bool ? i : (i is int) ? intToBool(i) : null;
  static BigInt asBigInt(String s) => s == null ? null : BigInt.tryParse(s);

  static DateTime asDateTime(String d) {
    if (d == null) {
      return null;
    }
    try {
      return DateTime.parse(d);
    } on FormatException {
      return null;
    }
  }

  static Uri asUri(String d) {
    if (d == null) {
      return null;
    }

    return Uri.tryParse(d);
  }

  /// Force interpretation of timestamp as UTC.
  /// This is required when parsing dates from endpoints which
  /// return utc timestamps as naive timestamps without "Z" terminus.
  static DateTime asUTCDateTime(String d) {
    if (d == null) {
      return null;
    }
    try {
      final utcStamp =  (d.endsWith("Z") || d.endsWith('+00:00')) ? d : "${d}Z";
      return DateTime.parse(utcStamp);
    } on FormatException {
      return null;
    }
  }

  static T fromJSON<T>(entity) {
    if (entity == null) {
      return null;
    }
    try {
      return jsonDecode(entity) as T;
    } catch (e) {
      return null;
    }
  }

  static T asObject<T>(dynamic o) {
    if (o == null) {
      return null;
    }
    try {
      return o as T;
    } on TypeError {
      return null;
    }
  }

  static String asHexColor(String rawColor) {
    if (rawColor == null) {
      return null;
    }

    String inColor = rawColor.replaceFirst("#", "").trim();

    try {
      int.parse(inColor, radix: 16);
    } on FormatException {
      // Not a hex string representation.
      return null;
    }

    switch(inColor.length) {
      case 8:
      // ARGB.
        return inColor;
      case 3:
      // RGB 3.
        StringBuffer outColor = StringBuffer();
        outColor.write("FF");
        for (int i = 0; i < inColor.length; i++) {
          outColor.write(inColor[i]);
          outColor.write(inColor[i]);
        }
        return outColor.toString();
      case 6:
      // RGB 6.
        StringBuffer outColor = StringBuffer();
        outColor.write("FF");
        outColor.write(inColor);
        return outColor.toString();
      default:
        return null;
    }
  }
}
