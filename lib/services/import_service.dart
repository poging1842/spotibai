import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:spotibai/models/song.dart';

class ImportService {
  static const List<String> _audioExtensions = [
    '.mp3',
    '.wav',
    '.flac',
    '.m4a',
    '.aac',
    '.ogg',
  ];

  Future<List<Song>> pickAudioFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'wav', 'flac', 'm4a', 'aac', 'ogg'],
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) {
      return const [];
    }

    final songs = <Song>[];
    for (final file in result.files) {
      if (file.path == null) {
        continue;
      }

      final song = Song.fromFilePath(file.path!);
      songs.add(song);
    }

    return songs;
  }

  Future<List<Song>> pickZipPlaylist() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty || result.files.first.path == null) {
      return const [];
    }

    final zipFile = File(result.files.first.path!);
    return _extractZipPlaylist(zipFile);
  }

  Future<List<Song>> _extractZipPlaylist(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final tempDir = await getTemporaryDirectory();
    final extractDir = Directory(
      '${tempDir.path}/spotibai_import/${DateTime.now().millisecondsSinceEpoch}',
    );
    await extractDir.create(recursive: true);

    final songs = <Song>[];
    for (final archiveFile in archive) {
      final extension = p.extension(archiveFile.name).toLowerCase();
      if (!archiveFile.isFile || !_audioExtensions.contains(extension)) {
        continue;
      }

      final sanitizedName = archiveFile.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final outputFile = File('${extractDir.path}/$sanitizedName');
      await outputFile.writeAsBytes(archiveFile.content as List<int>);
      songs.add(Song.fromFilePath(outputFile.path));
    }

    return songs;
  }
}
