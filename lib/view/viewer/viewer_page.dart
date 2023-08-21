import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:nas_photo_viewer/model/nas_file.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      widget.viewerPageBloc.loadFiles(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewerPageBloc.nasFilesStateProvider);
    final nasfiles = state.nasfiles;
    if (nasfiles.isNotEmpty) {
      return photoViewer(context, nasfiles);
    }
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget photoViewer(BuildContext context, List<List<NasFile>> nasfiles) {
    return Scaffold(
      appBar: null,
      body: Scrollbar(
        thumbVisibility: true,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(widget.viewerPageBloc.path),
            ),
            ...nasfiles
                .map((files) {
                  final date = files[0].getUpdatedDate();
                  return [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: 1,
                        (context, index) => Text(date,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                    SliverGrid.builder(
                      itemCount: files.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 180,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final nasfile = files[index];
                        Widget content;
                        if (nasfile.nasFileType == NasFileType.photo) {
                          final thumbnail =
                              '${widget.viewerPageBloc.getNasUrl()}rpc/thumbnail${nasfile.path}?size=3L';
                          final url =
                              '${widget.viewerPageBloc.getNasUrl()}rpc/cat';
                          final cookie = widget.viewerPageBloc.getNasCookie();
                          content = InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                ImageDetailPage.routeName,
                                arguments: {
                                  'index': index,
                                  'nasfiles': nasfiles
                                      .expand((element) => element)
                                      .toList(),
                                  'urlBase': url,
                                },
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: thumbnail,
                              httpHeaders: {
                                'Cookie': cookie,
                              },
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error_outlined,
                                size: 100,
                              ),
                              fit: BoxFit.fitWidth,
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
                    )
                  ];
                })
                .expand((e) => e)
                .toList(),
          ],
        ),
      ),
    );
  }
}
