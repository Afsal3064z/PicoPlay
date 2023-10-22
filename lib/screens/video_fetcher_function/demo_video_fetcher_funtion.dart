// This is the functon to load video from the device

import 'dart:io';
import 'package:mime/mime.dart';
import 'package:picoplay/dataBase/video_data_base_helper.dart';

class GetVideos {
  static List<String> cachedVideoPaths = [];
  static bool _isLoading = false;

  static Future<List<String>> getVideos() async {
    if (_isLoading) {
      return cachedVideoPaths;
    }

    _isLoading = true;

    List<String> videoPaths = await fetchAllVideos();
    cachedVideoPaths.addAll(videoPaths);

    await VideoDatabaseHelper.instance.insertVideoPaths(videoPaths);

    _isLoading = false;

    return videoPaths;
  }

  static Future<List<String>> fetchAllVideos() async {
    List<String> videoPaths = [];
    List<String> filePath = [];
// These are the formates to fetch from the device
    List<String> videoFormats = [
      'video/mp4',
      'video/mpeg',
      'video/quicktime',
      'video/x-msvideo',
      'video/x-matroska',
    ];
    // These are the resticed path to avoide exception
    // because the os wont give permission to access these path
    List<String> restrictedFiles = [
      '/storage/emulated/0/Android',
      '/storage/emulated/0/Android/obb',
      '/storage/emulated/0/Android/data',
    ];
// This is the root directory of the android
    Directory root = Directory('/storage/emulated/0/Android');
    root.listSync().forEach((element) {
      if (element is Directory) {
        filePath.add(element.path);
      }
    });
    root = Directory('/storage/emulated/0');
    root.listSync().forEach((element) {
      if (element is Directory) {
        filePath.add(element.path);
      }
    });
    for (final resPath in restrictedFiles) {
      if (filePath.contains(resPath)) {
        filePath.remove(resPath);
      }
    }

    for (final path in filePath) {
      final directory = Directory(path);
      if (directory.existsSync()) {
        directory.listSync(recursive: true).forEach((element) {
          if (element is File) {
            final mimeType = lookupMimeType(element.path);
            if (mimeType != null &&
                videoFormats.contains(mimeType) &&
                !element.path.contains('.trashed')) {
              videoPaths.add(element.path);
            }
          }
        });
      }
    }
    
    // The video paths are returned
    return videoPaths;
  }
  
}
