import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nas_photo_viewer/model/nas_file.dart';

@immutable
abstract class NasFilesState {
  final List<List<NasFile>> nasfiles;
  const NasFilesState(this.nasfiles);
}

@immutable
class NasFilesInitial extends NasFilesState {
  const NasFilesInitial(List<List<NasFile>> nasfiles) : super(nasfiles);
}

@immutable
class NasFilesLoading extends NasFilesState {
  const NasFilesLoading(List<List<NasFile>> nasfiles) : super(nasfiles);
}

@immutable
class NasFilesSuccess extends NasFilesState {
  const NasFilesSuccess(List<List<NasFile>> nasfiles) : super(nasfiles);
}

@immutable
class NasFilesFailure extends NasFilesState {
  final String error;
  const NasFilesFailure(List<List<NasFile>> nasfiles, this.error)
      : super(nasfiles);
}

class NasFilesNotifier extends StateNotifier<NasFilesState> {
  NasFilesNotifier(NasFilesState state) : super(state);

  void setState(NasFilesState state) {
    this.state = state;
  }
}
