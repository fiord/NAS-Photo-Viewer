import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:nas_photo_viewer/model/nas_file.dart';
import 'package:nas_photo_viewer/service/http/http_repository.dart';
import 'package:nas_photo_viewer/service/nasfiles/nasfiles_repository.dart';
import 'package:nas_photo_viewer/usecase/nas_files_state.dart';

class ViewerPageBloc {
  final HttpRepository httpRepository;
  final NasFilesRepository nasFilesRepository;
  final String path;
  final nasFilesStateProvider =
      StateNotifierProvider<NasFilesNotifier, NasFilesState>(
          (ref) => NasFilesNotifier(const NasFilesInitial([])));

  ViewerPageBloc({
    required this.httpRepository,
    required this.nasFilesRepository,
    this.path = '/',
  });

  String getNasUrl() {
    return httpRepository.getNasUrl();
  }

  String getNasCookie() {
    final cookies = httpRepository.getCookies();
    final ipCookie = cookies.entries.first.value;
    final pathCookie = ipCookie.entries.first.value;
    final webaxsSession = pathCookie.entries.first.value;
    final cookie = webaxsSession.cookie;
    return '${cookie.name}=${cookie.value}';
  }

  Future<List<NasFile>> _loadFiles(WidgetRef ref, String path) async {
    final List<NasFile> nasfiles = [];
    final queue = ListQueue<String>();
    queue.addLast(path);

    while (queue.isNotEmpty) {
      path = queue.removeFirst();
      Logger().d(path);
      final res =
          await httpRepository.get('${httpRepository.getNasUrl()}rpc/ls$path');
      final List<dynamic> json = res.data;
      final resNasFiles = json
          .map((e) => NasFile.fromJSON(e))
          .where((e) => !['.', '..', '.webaxs', 'trashbox'].contains(e.name))
          .toList();
      for (final nasFile in resNasFiles) {
        if (nasFile.directory) {
          queue.addLast(nasFile.path);
        } else if (nasFile.nasFileType != NasFileType.other) {
          nasfiles.add(nasFile);
        }
      }
    }
    return nasfiles;
  }

  Future<List<NasFile>> _loadFilesFromIndex(WidgetRef ref, String path) async {
    final List<NasFile> nasfiles = [];
    try {
      final res = await httpRepository
          .get('${httpRepository.getNasUrl()}rpc/cat$path/.webaxs/index.txt');
      final lines = (res.data as String).split("\n");
      for (final line in lines) {
        if (line.isEmpty) continue;
        final tokens = line.split(" ");
        final mtime = int.parse(tokens[0]);
        final file = "$path${tokens.sublist(1).join(" ")}";
        nasfiles.add(NasFile(
            ctime: mtime,
            mtime: mtime,
            atime: mtime,
            writable: true,
            name: file,
            path: file,
            directory: false,
            size: 1,
            nasFileType: nasFileTypeFromFileName(file)));
      }
      return nasfiles.reversed.toList();
    } catch (e) {
      Logger().d(e);
      return [];
    }
  }

  Future<void> loadFiles(WidgetRef ref) async {
    await httpRepository.init();
    List<List<NasFile>> prevState = ref.read(nasFilesStateProvider).nasfiles;
    // if the data is in the sharedpreferences, use it
    final savedFiles = await nasFilesRepository.getNasFiles();
    if (savedFiles != null && prevState.isEmpty) {
      prevState = savedFiles;
    }
    ref
        .read(nasFilesStateProvider.notifier)
        .setState(NasFilesLoading(prevState));
    try {
      // load file
      List<NasFile> nasfiles = await _loadFilesFromIndex(ref, path);
      if (nasfiles.isEmpty) {
        nasfiles = await _loadFiles(ref, path);
        nasfiles.sort((a, b) => (b.mtime - a.mtime));
      }
      final Map<String, List<NasFile>> nasfilesMap = {};
      for (final nasfile in nasfiles) {
        final date = nasfile.getUpdatedDate();
        if (nasfilesMap.containsKey(date)) {
          nasfilesMap[date]!.add(nasfile);
        } else {
          nasfilesMap[date] = [nasfile];
        }
      }
      Logger().d("load completed");
      final nasfilesList = nasfilesMap.values.toList();
      // save to sharedpreferences
      nasFilesRepository.saveNasFiles(nasfilesList);

      ref
          .read(nasFilesStateProvider.notifier)
          .setState(NasFilesSuccess(nasfilesList));
    } catch (e, stackTrace) {
      Logger().e("error", e, stackTrace);
      ref
          .read(nasFilesStateProvider.notifier)
          .setState(NasFilesFailure(prevState, e.toString()));
    }
  }
}
