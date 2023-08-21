import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum NasFileType {
  photo,
  video,
  audio,
  other,
}

NasFileType nasFileTypeFromFileName(String filename) {
  if (filename.toLowerCase().endsWith(".jpg") ||
      filename.toLowerCase().endsWith(".jpeg") ||
      filename.toLowerCase().endsWith(".png")) {
    return NasFileType.photo;
  } else if (filename.toLowerCase().endsWith(".mp4") ||
      filename.toLowerCase().endsWith(".avi")) {
    return NasFileType.video;
  } else {
    return NasFileType.other;
  }
}

@immutable
class NasFile {
  final int ctime;
  final int mtime;
  final int atime;
  final bool writable;
  final String name;
  final String path;
  final bool directory;
  final int size;
  final NasFileType nasFileType;

  const NasFile({
    required this.ctime,
    required this.mtime,
    required this.atime,
    required this.writable,
    required this.name,
    required this.path,
    required this.directory,
    required this.size,
    required this.nasFileType,
  });

  Map<String, dynamic> get toJSON => {
        'ctime': ctime,
        'mtime': mtime,
        'atime': atime,
        'writable': writable,
        'name': name,
        'path': path,
        'directory': directory,
        'size': size,
      };

  factory NasFile.fromJSON(Map<String, dynamic> json) {
    final name = json['name'] ?? '';
    final nasFileType = nasFileTypeFromFileName(name);
    return NasFile(
      ctime: json['ctime'] ?? 0,
      mtime: json['mtime'] ?? 0,
      atime: json['atime'] ?? 0,
      writable: json['writable'] ?? false,
      name: name,
      path: json['path'] ?? '',
      directory: json['directory'] ?? false,
      size: json['size'] ?? 0,
      nasFileType: nasFileType,
    );
  }

  String getUpdatedDate() {
    final date = DateTime.fromMillisecondsSinceEpoch(mtime * 1000);
    final key = DateFormat('yyyy/MM/dd').format(date);
    return key;
  }
}
