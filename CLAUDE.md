# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Lint / analyze
flutter analyze

# Build for iOS
flutter build ios

# Build for Android
flutter build apk
```

## Architecture

This is a Flutter app (Dart) targeting iOS primarily, with support for other platforms. Entry point is `lib/main.dart`, which sets up the theme and launches `NaelScreen` directly (not `HomeScreen` — the home screen exists but is currently unused as the root).

### Screen Flow

- `NaelScreen` — the actual app root. Shows a curated grid of personal media items (YouTube videos + YouTube Music tracks). Tapping opens the item in the appropriate external app.
- `HomeScreen` — exists but is not wired as the root. Has buttons to navigate to both `PlaylistScreen` and `NaelScreen`.
- `PlaylistScreen` — filters Korean CCM playlists by mood (경배/묵상/찬양) and genre (CCM/워십/찬송가), fetched from an AWS Lambda API.

### Services

- `ApiService` — fetches playlists from `https://e3paoyoy8c.execute-api.us-west-1.amazonaws.com/prod`. Falls back to mock data on error. `getNaelMedia()` always returns hardcoded mock data (no real API call).
- `UrlLauncherService` — deep-links into YouTube app (iOS: `youtube://` scheme with canLaunch fallback to browser) or YouTube Music. Uses `url_launcher` with `LaunchMode.externalApplication`.

### Key Patterns

- All screens use a purple gradient background (`0xFF667eea` → `0xFF764ba2`).
- Korean typography via `google_fonts` (Noto Sans KR).
- API errors show a red `SnackBar`; missing media shows an empty-state widget.
- The app is private (`publish_to: none`), version `1.1.0+3`, requires Dart SDK `^3.9.0`.
