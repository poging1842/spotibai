import 'dart:io';

import 'package:path/path.dart' as p;

class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.filePath,
    required this.extension,
  });

  final String id;
  final String title;
  final String artist;
  final String filePath;
  final String extension;

  factory Song.fromFilePath(String path) {
    final fileName = p.basename(path);
    final withoutExtension = p.basenameWithoutExtension(fileName);

    return Song(
      id: path,
      title: withoutExtension,
      artist: 'Local Artist',
      filePath: path,
      extension: p.extension(fileName).replaceFirst('.', '').toUpperCase(),
    );
  }

  bool get isLocalFile => File(filePath).existsSync();
}
