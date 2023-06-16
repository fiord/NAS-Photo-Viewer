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

  Future<void> loadFiles(WidgetRef ref) async {
    Logger().d("loadFiles called");
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
          .where((e) => !['.', '..'].contains(e.name))
          .toList();
      Logger().d(nasfiles.map((e) => e.name));
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
