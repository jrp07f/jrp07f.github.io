import 'package:care_dart_sdk/utilities/string_utils.dart';

class KeyStore {
  static const kGingerCredentialsUserId = "kGingerCredentialsUserId";
  static const kGingerCredentialsServerSecret = "kGingerCredentialsServerSecret";
  static const kGingerCredentialsJWT = "kGingerCredentialsJWT";
  static const kListenerCredentialsListenerUserId = "kListenerCredentialsListenerUserId";
  static const kListenerCredentialsListenerAuthToken = "kListenerCredentialsListenerAuthToken";
  static const kPubNubCredentialsAuthToken = "kPubNubCredentialsAuthToken";
  static const kPubNubCredentialsPubKey = "kPubNubCredentialsPubKey";
  static const kPubNubCredentialsSubKey = "kPubNubCredentialsSubKey";
}

class GingerCredentials {
  int userId;
  String serverSecret;

  GingerCredentials(this.userId, this.serverSecret);
}

class ListenerCredentials {
  int listenerUserId;
  String listenerAuthToken;

  ListenerCredentials(this.listenerUserId, this.listenerAuthToken);
}

class PubNubCredentials {
  String uuid;
  String subKey;
  String pubKey;
  String authToken;

  PubNubCredentials(this.uuid, this.subKey, this.pubKey, this.authToken);
}

class CredentialsBundle {
  GingerCredentials gingerCredentials;
  ListenerCredentials listenerCredentials;
  PubNubCredentials pubNubCredentials;

  CredentialsBundle(
    this.gingerCredentials,
    this.listenerCredentials,
    this.pubNubCredentials,
  );

  static CredentialsBundle fromMap(Map<dynamic, dynamic> map){

    if (map == null)
      return null;

    String gcServerSecret = map[KeyStore.kGingerCredentialsServerSecret];
    int gcUserId = int.parse(
        map[KeyStore.kGingerCredentialsUserId].toString());
    String lcAuthToken = map[KeyStore
        .kListenerCredentialsListenerAuthToken];
    int lcUserId = int.parse(
        map[KeyStore.kListenerCredentialsListenerUserId].toString());
    String pnAuthToken = map[KeyStore.kPubNubCredentialsAuthToken];
    String pnSubkey = map[KeyStore.kPubNubCredentialsSubKey];
    String pnPubKey = map[KeyStore.kPubNubCredentialsPubKey];

    if (gcUserId == null || lcUserId == null ||
        StringUtils.isEmpty(gcServerSecret) ||
        StringUtils.isEmpty(lcAuthToken) ||
        StringUtils.isEmpty(pnAuthToken) ||
        StringUtils.isEmpty(pnSubkey) || StringUtils.isEmpty(pnPubKey)) {
      return null;
    }

    GingerCredentials gingerCredentials = GingerCredentials(
        gcUserId, gcServerSecret);
    ListenerCredentials listenerCredentials = ListenerCredentials(
        lcUserId, lcAuthToken);
    PubNubCredentials pubNubCredentials = PubNubCredentials(
        lcUserId.toString(), pnSubkey, pnPubKey, pnAuthToken);
    return CredentialsBundle(
        gingerCredentials, listenerCredentials, pubNubCredentials);
  }
}
