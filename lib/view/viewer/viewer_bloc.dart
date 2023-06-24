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

  Future<void> loadFiles(WidgetRef ref) async {
    await httpRepository.init();
    final prevState = ref.read(nasFilesStateProvider).nasfiles;
    ref
        .read(nasFilesStateProvider.notifier)
        .setState(NasFilesLoading(prevState));
    try {
      // load file
      final res =
          await httpRepository.get('${httpRepository.getNasUrl()}rpc/ls$path');
      final List<dynamic> json = res.data;
      final nasfiles = json
          .map((e) => NasFile.fromJSON(e))
          .where((e) => !['.', '..', '.webaxs'].contains(e.name))
          .toList();
      nasfiles.sort((a, b) => (a.ctime - b.ctime));
      // Logger().d(nasfiles.map((e) => e.name));
      ref
          .read(nasFilesStateProvider.notifier)
          .setState(NasFilesSuccess(nasfiles));
    } catch (e) {
      Logger().e(e);
      ref
          .read(nasFilesStateProvider.notifier)
          .setState(NasFilesFailure(prevState, e.toString()));
    }
  }
}
