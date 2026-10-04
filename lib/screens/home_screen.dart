import 'package:flutter/material.dart';

import 'package:spotibai/models/song.dart';
import 'package:spotibai/services/import_service.dart';
import 'package:spotibai/services/music_library_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MusicLibraryService _library = MusicLibraryService();
  final ImportService _importService = ImportService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _library.initialize();
  }

  @override
  void dispose() {
    _library.dispose();
    super.dispose();
  }

  Future<void> _addSongsFromPicker() async {
    setState(() => _loading = true);
    final songs = await _importService.pickAudioFiles();
    if (!mounted) {
      return;
    }

    if (songs.isNotEmpty) {
      await _library.appendSongs(songs);
      setState(() {});
    }

    setState(() => _loading = false);
  }

  Future<void> _addSongsFromZip() async {
    setState(() => _loading = true);
    final songs = await _importService.pickZipPlaylist();
    if (!mounted) {
      return;
    }

    if (songs.isNotEmpty) {
      await _library.appendSongs(songs);
      setState(() {});
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _library.currentSong;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2F4),
      appBar: AppBar(
        toolbarHeight: 104,
        backgroundColor: const Color(0xFF0D6469),
        elevation: 0,
        title: Row(
          children: const [
            Expanded(
              child: Text(
                'Files: Spotibai',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 16),
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 42),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _addSongsFromPicker,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Add songs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6469),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _addSongsFromZip,
                    icon: const Icon(Icons.archive_rounded),
                    label: const Text('Import ZIP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F1F1F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _library.hasSongs
                ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _library.songs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final song = _library.songs[index];
                      final selected = currentSong?.id == song.id;

                      return ListTile(
                        tileColor: selected ? const Color(0xFF1AA39A).withOpacity(0.15) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: selected ? const Color(0xFF0D6469) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E5E5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.music_note_rounded, color: Color(0xFF1F1F1F)),
                        ),
                        title: Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2A2A2A),
                          ),
                        ),
                        subtitle: Text(
                          '${song.artist} • ${song.extension}',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF6A6A6A)),
                        ),
                        trailing: IconButton(
                          onPressed: () => _library.playSongAt(index),
                          icon: const Icon(Icons.play_arrow_rounded, size: 30),
                          color: const Color(0xFF0D6469),
                        ),
                        onTap: () => _library.playSongAt(index),
                      );
                    },
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No songs yet. Upload a file or ZIP playlist to begin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3A3A3A),
                        ),
                      ),
                    ),
                  ),
          ),
          if (currentSong != null)
            Container(
              height: 94,
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF1B1B1B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.library_music_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          currentSong.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _library.previous(),
                    icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
                  ),
                  IconButton(
                    onPressed: () => _library.togglePlayPause(),
                    icon: Icon(
                      _library.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _library.next(),
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                  ),
                  IconButton(
                    onPressed: () => _library.toggleShuffle(),
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: _library.isShuffleEnabled ? const Color(0xFF58D6AB) : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
