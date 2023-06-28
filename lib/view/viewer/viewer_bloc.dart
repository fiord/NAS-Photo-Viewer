import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:nas_photo_viewer/model/nas_file.dart';
import 'package:nas_photo_viewer/service/http/http_repository.dart';
import 'package:nas_photo_viewer/usecase/nas_files_state.dart';

class ViewerPageBloc {
  final HttpRepository httpRepository;
  final String path;
  final nasFilesStateProvider =
      StateNotifierProvider<NasFilesNotifier, NasFilesState>(
          (ref) => NasFilesNotifier(const NasFilesInitial([])));

  ViewerPageBloc({
    required this.httpRepository,
    this.path = '/',
  });

  String getNasUrl() {
    return httpRepository.getNasUrl();
  }

  String getNasCookie() {
    final cookies = httpRepository.getCookies();
    Logger().d(cookies.toString());
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

  Future<void> loadFiles(WidgetRef ref) async {
    await httpRepository.init();
    final prevState = ref.read(nasFilesStateProvider).nasfiles;
    ref
        .read(nasFilesStateProvider.notifier)
        .setState(NasFilesLoading(prevState));
    try {
      // load file
      final nasfiles = await _loadFiles(ref, path);
      nasfiles.sort((a, b) => (a.ctime - b.ctime));
      // Logger().d(nasfiles.map((e) => e.name));
      Logger().d("load completed");
      ref
          .read(nasFilesStateProvider.notifier)
          .setState(NasFilesSuccess(nasfiles));
    } catch (e, stackTrace) {
      Logger().e("error", e, stackTrace);
      ref
          .read(nasFilesStateProvider.notifier)
          .setState(NasFilesFailure(prevState, e.toString()));
    }
  }
}
