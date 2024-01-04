import 'dart:convert';

import 'package:care_dart_sdk/utilities/string_utils.dart';
import 'package:mini_ginger_web/commons/serialization.dart';
import 'package:care_dart_sdk/utilities/word_capitalizer.dart';

class HSMemberInfo {
  final String userId;
  final String name;
  final String email;
  final List<String> privileges;

  final String raw;

  HSMemberInfo({this.userId, this.name, this.privileges, this.email, this.raw});

  factory HSMemberInfo.fromMap(Map<String, dynamic> data) {
    String name = PreserveNull.asString(data["firstName"]);
    List<String> privileges = [];
    if (data["privileges"] != null && data["privileges"] is List) {
      privileges =
          List<String>.from(data["privileges"].map((x) => x.toString()));
    }

    if (StringUtils.isEmpty(name)) {
      String nickname = PreserveNull.asString(data['email']);
      name = nickname?.split('.')?.first;
    }

    return HSMemberInfo(
        userId: data["hsId"],
        email: data["email"],
        privileges: privileges,
        name: name?.capitalize(),
        raw: jsonEncode(data));
  }
}
