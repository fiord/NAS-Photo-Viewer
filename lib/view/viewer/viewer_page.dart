import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:nas_photo_viewer/model/nas_file.dart';
import 'package:nas_photo_viewer/usecase/nas_files_state.dart';
import 'package:nas_photo_viewer/view/image_detail/image_detail.dart';
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
          SliverAppBar(
            title: Text(widget.viewerPageBloc.path),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 3,
              crossAxisSpacing: 5,
              childAspectRatio: 1.2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final nasfile = nasfiles[index];
                Logger().d('nasfile name=${nasfile.path}');
                Widget content;
                if (nasfile.directory) {
                  content = Card(
                    margin: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(ViewerPage.routeName,
                            arguments: nasfile.path);
                      },
                      borderRadius: BorderRadius.circular(18.0),
                      child: Column(
                        children: [
                          const Expanded(
                            // width: 400
                            child: Icon(
                              Icons.folder,
                              size: 100,
                            ),
                          ),
                          Text(nasfile.name),
                        ],
                      ),
                    ),
                  );
                } else if (nasfile.nasFileType == NasFileType.photo) {
                  final thumbnail =
                      '${widget.viewerPageBloc.getNasUrl()}rpc/cat';
                  final url = '${widget.viewerPageBloc.getNasUrl()}rpc/cat';
                  final cookie = widget.viewerPageBloc.getNasCookie();
                  content = InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ImageDetailPage.routeName,
                        arguments: {
                          'index': index,
                          'nasfiles': nasfiles,
                          'urlBase': url,
                        },
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: '$thumbnail${nasfile.path}',
                      httpHeaders: {
                        'Cookie': cookie,
                      },
                      progressIndicatorBuilder: (context, url, progress) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error_outlined,
                        size: 100,
                      ),
                    ),
                  );
                } else if (nasfile.nasFileType == NasFileType.video) {
                  content = const Center(
                    child: Icon(
                      Icons.video_call_outlined,
                      size: 100,
                    ),
                  );
                } else {
                  content = const Center(
                    child: Icon(
                      Icons.file_open,
                      size: 100,
                    ),
                  );
                }
                return content;
              },
              childCount: nasfiles.length,
            ),
          ),
        ],
      ),
    );
  }
}
