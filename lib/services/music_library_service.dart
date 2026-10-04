import 'dart:async';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import 'package:spotibai/models/song.dart';

class MusicLibraryService {
  MusicLibraryService();

  final AudioPlayer _player = AudioPlayer();
  final List<Song> _songs = [];
  final List<int> _shuffleOrder = [];
  bool _shuffleEnabled = false;
  int _currentIndex = -1;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  AudioPlayer get player => _player;

  List<Song> get songs => List.unmodifiable(_songs);
  bool get hasSongs => _songs.isNotEmpty;
  bool get isShuffleEnabled => _shuffleEnabled;
  bool get isPlaying => _player.playing;
  Song? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _songs.length ? _songs[_currentIndex] : null;

  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> setSongs(List<Song> songs) async {
    _songs
      ..clear()
      ..addAll(songs);

    if (_songs.isEmpty) {
      _currentIndex = -1;
      await _player.stop();
      return;
    }

    _currentIndex = 0;
    _shuffleOrder.clear();
    await _loadCurrentSong();
  }

  Future<void> appendSongs(List<Song> songs) async {
    if (songs.isEmpty) {
      return;
    }

    _songs.addAll(songs);
    if (_currentIndex == -1) {
      _currentIndex = 0;
      await _loadCurrentSong();
    }
  }

  Future<void> playSongAt(int index) async {
    if (index < 0 || index >= _songs.length) {
      return;
    }

    _currentIndex = index;
    await _loadCurrentSong();
    await _player.play();
  }

  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;

    if (_shuffleEnabled) {
      _shuffleOrder
        ..clear()
        ..addAll(List<int>.generate(_songs.length, (index) => index));
      _shuffleOrder.shuffle(Random());

      if (_currentIndex >= 0 && _shuffleOrder.contains(_currentIndex)) {
        _shuffleOrder.remove(_currentIndex);
        _shuffleOrder.insert(0, _currentIndex);
      }
    } else {
      _shuffleOrder.clear();
    }
  }

  Future<void> togglePlayPause() async {
    if (_songs.isEmpty) {
      return;
    }

    if (_player.playing) {
      await _player.pause();
    } else {
      if (_currentIndex == -1) {
        _currentIndex = 0;
        await _loadCurrentSong();
      }
      await _player.play();
    }
  }

  Future<void> next() async {
    if (_songs.isEmpty) {
      return;
    }

    if (_shuffleEnabled) {
      final nextIndex = _getNextShuffleIndex();
      if (nextIndex != -1) {
        await playSongAt(nextIndex);
      }
      return;
    }

    final nextIndex = (_currentIndex + 1) % _songs.length;
    await playSongAt(nextIndex);
  }

  Future<void> previous() async {
    if (_songs.isEmpty) {
      return;
    }

    if (_shuffleEnabled) {
      final previousIndex = _getPreviousShuffleIndex();
      if (previousIndex != -1) {
        await playSongAt(previousIndex);
      }
      return;
    }

    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }

    final previousIndex = _currentIndex <= 0 ? _songs.length - 1 : _currentIndex - 1;
    await playSongAt(previousIndex);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  Future<void> _loadCurrentSong() async {
    if (_currentIndex < 0 || _currentIndex >= _songs.length) {
      return;
    }

    final song = _songs[_currentIndex];
    await _player.setFilePath(song.filePath);
  }

  int _getNextShuffleIndex() {
    if (_shuffleOrder.isEmpty) {
      return -1;
    }

    final currentPosition = _shuffleOrder.indexOf(_currentIndex);
    if (currentPosition == -1) {
      return _shuffleOrder.first;
    }

    final nextPosition = (currentPosition + 1) % _shuffleOrder.length;
    return _shuffleOrder[nextPosition];
  }

  int _getPreviousShuffleIndex() {
    if (_shuffleOrder.isEmpty) {
      return -1;
    }

    final currentPosition = _shuffleOrder.indexOf(_currentIndex);
    if (currentPosition == -1) {
      return _shuffleOrder.last;
    }

    final previousPosition = currentPosition == 0 ? _shuffleOrder.length - 1 : currentPosition - 1;
    return _shuffleOrder[previousPosition];
  }
}
