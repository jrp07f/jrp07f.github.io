import 'package:mini_ginger_web/commons/serialization.dart';

enum StaffRole {
  coach,
  onCall,
  support,
  therapist,
  concierge,
  backup,
  other
}

/// Staff member.
class Staff {
  int listenerId;
  String name;
  String bio; // Description.
  String imageURLRaw;
  int displayOrder = 0;
  String roleRaw = "COACH";
  String roleAliasRaw = "COACH";
  bool isOnline = false;
  String status = "";
  String channelId;
  String broadcastChannelId;
  int tableVersion;
  String introVideoURL;
  List<String> languages;

  /// If false, then we don't allow the user to send messages to this staff member. Can be used
  /// for coaches that are no longer present, or if the user hits a paywall and can only talk
  /// to member support.
  bool enabled = true;

  /// Shown as a part of the care team if true.
  bool archived = false;

  /// Ask the member to rate their coach if true.
  bool showRating = false;

  Staff({
    this.listenerId,
    this.name,
    this.bio,
    this.imageURLRaw,
    this.displayOrder,
    this.roleRaw,
    this.roleAliasRaw,
    this.isOnline,
    this.status,
    this.archived,
    this.enabled = true,
    this.showRating,
    this.introVideoURL,
    this.channelId,
    this.broadcastChannelId,
    this.tableVersion,
    this.languages,
  });

  static StaffRole roleFromString(String role) {
    switch (role) {
      case "COACH":
        return StaffRole.coach;
      case "ONCALL":
        return StaffRole.onCall;
      case "SUPPORT":
        return StaffRole.support;
      case "THERAPIST":
        return StaffRole.therapist;
      case "CONCIERGE":
        return StaffRole.concierge;
      case "BACKUP":
        return StaffRole.backup;
      case "OTHER":
      default:
        return StaffRole.other;
    }
  }

  /// Convert server JSON object into local Staff object.
  factory Staff.fromJSON(int index, Map<String, dynamic> data) {
    return Staff(
      displayOrder: index,
      listenerId: JSON.valueAsInt(data["listenerId"]),
      name: data["alias"],
      bio: data["listenerDescription"],
      imageURLRaw: data["imageUrl"],
      roleRaw: data["role"],
      roleAliasRaw: data["roleAlias"],
      isOnline: data["chatEnabled"],
      status: data["listenerStatus"],
      enabled: data["allowsInput"],
      archived: !(data["isVisible"] as bool),
      showRating: data["showRating"],
      introVideoURL: data["introVideoURL"],
      channelId: data["channel_id"],
      broadcastChannelId: data["broadcastChannel"],
      languages: List<String>.from(data["listenerLanguages"] ?? []),
    );
  }

  /// Convert staff object to json object acceptable to server.
  Map<String, dynamic> toJSON() {
    return {
      "listenerId": listenerId,
      "alias": name,
      "listenerDescription": bio,
      "imageUrl": imageURLRaw,
      "role": roleRaw,
      "roleAlias": roleAliasRaw,
      "chatEnabled": isOnline,
      "listenerStatus": status,
      "allowsInput": enabled,
      "isVisible": !archived,
      "showRating": showRating,
      "introVideoURL": introVideoURL,
      "channel_id": channelId,
      "broadcastChannel": broadcastChannelId
    };
  }

  StaffRole get role => Staff.roleFromString(roleRaw);

  bool get isOnlineCoach => isOnline && !archived && [StaffRole.coach, StaffRole.backup, StaffRole.onCall].contains(role);
}

