{{flutter_js}}
{{flutter_build_config}}

// Without serviceWorkerSettings: Flutter's service worker is deprecated, and registering it made the first visit
// wait before the app started downloading (docs/DEPLOY.md).
_flutter.loader.load();
