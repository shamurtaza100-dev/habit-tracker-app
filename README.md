# Habit Tracker

A modern offline-first Habit Tracker mobile app starter built with Flutter, Riverpod, Hive, go_router, fl_chart, and local notifications.

## Features

- Add unlimited daily or weekly habits
- Mark habits complete for today
- View progress, streaks, and a 30-day completion chart
- Archive habits without deleting completion history
- Dark mode via system theme
- Local reminder service scaffold
- Clean feature-based folder structure

## Getting Started

Flutter is not installed in this workspace environment, so platform folders were not generated here. On a machine with Flutter installed, run:

```bash
flutter create --platforms=android,ios .
flutter pub get
flutter run
```

If `flutter create .` asks to overwrite files, keep the existing `lib/`, `pubspec.yaml`, `README.md`, and `analysis_options.yaml` files from this project.

## Release Builds

```bash
flutter build apk --release
flutter build appbundle --release
```

The Android release APK is generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```
