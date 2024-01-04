import 'package:logging/logging.dart';

extension LevelStringExtension on String {
  Level toLevel() {
    switch (toUpperCase()) {
      case "FINEST":
        return Level.FINEST;
      case "FINER":
        return Level.FINER;
      case "FINE":
        return Level.FINE;
      case "INFO":
        return Level.INFO;
      case "WARNING":
        return Level.WARNING;
      case "CONFIG":
        return Level.CONFIG;
      case "SEVERE":
        return Level.SEVERE;
      case "SHOUT":
        return Level.SHOUT;
      case "OFF":
        return Level.OFF;
      default:
        return Level.ALL;
    }
  }
}
