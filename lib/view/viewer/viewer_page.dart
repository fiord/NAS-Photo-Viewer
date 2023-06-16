import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nas_photo_viewer/model/nas_file.dart';
import 'package:nas_photo_viewer/usecase/nas_files_state.dart';
import 'package:nas_photo_viewer/view/viewer/viewer_bloc.dart';

class ViewerPage extends ConsumerStatefulWidget {
  static const String routeName = '/viewer';
  final ViewerPageBloc viewerPageBloc;

  const ViewerPage({super.key, required this.viewerPageBloc});

  @override
  ViewerPageState createState() => ViewerPageState();
}

class ViewerPageState extends ConsumerState<ViewerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.viewerPageBloc.loadFiles(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewerPageBloc.nasFilesStateProvider);
    if (state is NasFilesSuccess) {
      return photoViewer(context, state.nasfiles);
    }
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget photoViewer(BuildContext context, List<NasFile> nasfiles) {
    return Scaffold(
      appBar: null,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Photo'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Text(nasfiles[index].name),
              childCount: nasfiles.length,
            ),
          ),
        ],
      ),
    );
  }
}
