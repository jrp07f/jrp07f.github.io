import 'package:flutter/material.dart';

/// These keys are NOT declared final so they are overridable in non-widget unit tests
class Keys {
  static GlobalKey<State<StatefulWidget>> guardianConsentScreenKey = GlobalKey<State<StatefulWidget>>();
  static GlobalKey<State<StatefulWidget>> teenClinicalEscalationScreenKey = GlobalKey<State<StatefulWidget>>();
}