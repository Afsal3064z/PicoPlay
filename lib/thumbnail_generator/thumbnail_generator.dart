import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailGenerator extends StatefulWidget {
  final String videoPath;

  const ThumbnailGenerator({Key? key, required this.videoPath})
      : super(key: key);

  @override
  ThumbnailGeneratorState createState() => ThumbnailGeneratorState();

  generateVideoThumbnail() {}
}

class ThumbnailGeneratorState extends State<ThumbnailGenerator> {
  Uint8List? _thumbnail;

  @override
  void initState() {
    super.initState();
    // Generate the video thumbnail when the widget is initialized
    _generateVideoThumbnail();
  }

  Future<void> _generateVideoThumbnail() async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: widget.videoPath,
      imageFormat: ImageFormat.JPEG,
      quality: 80,
      maxWidth: 150,
      maxHeight: 150,
    );

    if (mounted) {
      setState(() {
        _thumbnail = thumbnail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_thumbnail != null) {
      // If the thumbnail is available, display it as an Image
      return Image.memory(_thumbnail!);
    } else {
      // If the thumbnail is not available yet, show a placeholder or loading indicator
      return const CircularProgressIndicator();
    }
  }
}
