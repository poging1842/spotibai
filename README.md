# Spotibai

A simple Spotify-inspired offline music player built with Flutter.

Features:
- Local music upload from .mp3, .wav, .flac, .m4a, .aac and .ogg files
- ZIP playlist import where songs inside the archive are added to the queue
- Offline playback using `just_audio`
- Spotify-inspired dark UI
- Shuffle mode and standard playback controls

## Run locally

1. Install Flutter.
2. From the project root, run:
   ```bash
   flutter pub get
   flutter run
   ```

## Notes

- The app uses local file selection, so the device must allow access to the chosen files.
- ZIP playlists are extracted to the app temporary directory before playback.
