# mini_ginger_web

Mini Standalone Flutter Web App

## Getting Started

### Building from the command line 
```bash
flutter packages upgrade
flutter run lib/main.dart -d chrome --web-port=63634 --dart-define="ENV_TYPE=WEB_STAGING" --dart-define="BUNDLED_CONTENT_VERSION=2139000" --web-browser-flag "--disable-web-security"
```

### Building from the command line connected to a local ginger server 
```bash
flutter packages upgrade
flutter run lib/main.dart -d chrome --web-port=63634 --dart-define="ENV_TYPE=WEB_STAGING" --dart-define="BUNDLED_CONTENT_VERSION=2139000" --dart-define=GINGER_BASE_URL="http://localhost:8002" --web-browser-flag "--disable-web-security"
```

It might be needed to run this:
```bash
flutter packages pub global activate intl_utils 1.9.0 && flutter pub global run intl_utils:generate
```

### Updating activities_metadata_root.json
Since flutter web doesnt have a filesystem to store/cache files, we cannot rely on the content sync service to fetch the latest `activities_metadata_root.json` based on the environment (dev/prod)
To be able to fetch the latest activities_metadata_root.json, please update the this file with the required changes in the `care_dart_sdk`.