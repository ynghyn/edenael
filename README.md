# EdeNael

A Flutter app for Korean Christian worship music and children's media.

## Features

### CCM Playlist Browser
Browse Korean Christian music (CCM) playlists filtered by:
- **Mood**: 경배 (Worship), 묵상 (Meditation), 찬양 (Praise)
- **Genre**: CCM, 워십 (Worship), 찬송가 (Hymns)

Playlists are fetched from an AWS Lambda API and open directly in the YouTube app.

### 나엘 미디어 (Nael Media)
A curated grid of personal media items — YouTube videos and YouTube Music tracks — displayed with thumbnails. Tapping an item opens it in the appropriate app (YouTube or YouTube Music).

## Tech Stack

- **Flutter** (Dart) — cross-platform mobile app
- **Google Fonts** — Noto Sans KR for Korean typography
- **http** — REST API calls to AWS Lambda backend
- **url_launcher** — deep links to YouTube / YouTube Music

## Project Structure

```
lib/
  main.dart               # App entry point, theme setup
  screens/
    home_screen.dart      # Home screen with navigation to CCM and Nael sections
    playlist_screen.dart  # CCM playlist browser with mood/genre filters
    nael_screen.dart      # Nael media grid (videos + music)
  services/
    api_service.dart      # API client + data models (Playlist, MediaItem)
    url_launcher_service.dart  # URL deep-link helpers for YouTube
```

## Getting Started

```bash
flutter pub get
flutter run
```

Requires Flutter SDK `^3.9.0`.
