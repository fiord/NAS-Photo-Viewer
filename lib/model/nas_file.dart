import 'package:flutter/material.dart';

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

  const NasFile({
    required this.ctime,
    required this.mtime,
    required this.atime,
    required this.writable,
    required this.name,
    required this.path,
    required this.directory,
    required this.size,
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
    return NasFile(
      ctime: json['ctime'] ?? 0,
      mtime: json['mtime'] ?? 0,
      atime: json['atime'] ?? 0,
      writable: json['writable'] ?? false,
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      directory: json['directory'] ?? false,
      size: json['size'] ?? 0,
    );
  }
}
