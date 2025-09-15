# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter CRM application named `nr_crm_flutter`. It's a fresh Flutter project with the standard counter demo app as a starting point. The app supports multiple platforms: iOS, Android, Windows, macOS, Linux, and Web.

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app on connected device/emulator
- `flutter run -d windows` - Run on Windows
- `flutter run -d chrome` - Run on Web
- `flutter hot-reload` - Hot reload changes (press 'r' in terminal)
- `flutter hot-restart` - Hot restart app (press 'R' in terminal)

### Building
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build windows` - Build Windows app
- `flutter build web` - Build web app

### Dependencies and Packages
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter pub outdated` - Check for outdated packages

### Code Quality
- `flutter analyze` - Run static analysis with lints from flutter_lints package
- `flutter test` - Run all tests
- `flutter test test/widget_test.dart` - Run specific test file

### Device Management
- `flutter devices` - List available devices/emulators
- `flutter emulators` - List available emulators
- `flutter emulators --launch <emulator_id>` - Launch specific emulator

## Project Structure

### Core Directories
- `lib/` - Main Dart source code
  - `lib/main.dart` - App entry point with MyApp and MyHomePage widgets
- `test/` - Test files
  - `test/widget_test.dart` - Widget tests for main counter functionality
- Platform-specific directories:
  - `android/` - Android configuration and resources
  - `ios/` - iOS configuration and resources
  - `windows/` - Windows configuration and resources
  - `macos/` - macOS configuration and resources
  - `linux/` - Linux configuration and resources
  - `web/` - Web configuration and resources

### Configuration Files
- `pubspec.yaml` - Project dependencies and metadata
- `analysis_options.yaml` - Dart analyzer configuration with flutter_lints rules

## Dependencies

### Current Dependencies
- `flutter` - Flutter SDK
- `cupertino_icons: ^1.0.8` - iOS-style icons

### Dev Dependencies
- `flutter_test` - Flutter testing framework
- `flutter_lints: ^5.0.0` - Recommended lints for Flutter

## Architecture Notes

This is currently a standard Flutter starter project with:
- Material Design theme using `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`
- Stateful widget pattern for the home page with counter state
- Standard Flutter project structure across all supported platforms

The app uses `package:flutter_lints/flutter.yaml` for code analysis rules, ensuring consistent code quality standards.