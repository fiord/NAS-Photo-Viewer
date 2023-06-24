import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nas_photo_viewer/model/nas_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageDetailPage extends StatefulWidget {
  static const routeName = "/detail";
  final List<NasFile> nasfiles;
  final int index;
  final String urlBase;
  const ImageDetailPage({
    super.key,
    required this.nasfiles,
    required this.index,
    required this.urlBase,
  });

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: widget.index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('test'),
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.nasfiles.length,
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(
                '${widget.urlBase}${widget.nasfiles[index].path}'),
            maxScale: PhotoViewComputedScale.covered * 5,
            minScale: PhotoViewComputedScale.contained,
          );
        },
        loadingBuilder: (context, event) =>
            const Center(child: CircularProgressIndicator()),
        pageController: _pageController,
      ),
    );
  }
}
