import 'package:flutter/material.dart';

import '../entity/object.dart';

abstract final class FormatConverter {
  static IconSourceType converter(String? objectKey) {
    if (objectKey == null) {
      return IconSourceType.bucket;
    }
    final end = objectKey.split('.').last.toLowerCase();
    final folder = objectKey.endsWith('/');
    if (folder) {
      return IconSourceType.folder;
    } else {
      switch (end) {
        case 'jpg':
        case 'jpeg':
        case 'webm':
        case 'png':
        case 'svg':
        case 'tiff':
        case 'webp':
        case 'gif':
        case 'bmp':
        case 'tif':
          return IconSourceType.image;
        case 'html':
        case 'txt':
        case 'doc':
        case 'pdf':
        case 'xls':
          return IconSourceType.doc;
        case 'zip':
        case 'rar':
          return IconSourceType.archive;
        case 'exe':
        case 'apk':
        case 'aab':
        case 'app':
          return IconSourceType.program;
        case 'wav':
        case 'mp3':
        case 'wma':
        case 'aac':
        case 'flac':
          return IconSourceType.music;
        case 'mp4':
        case 'mob':
        case 'mkv':
        case 'm4v':
        case 'avi':
        case 'flv':
        case '3gp':
          return IconSourceType.video;
        default:
          return IconSourceType.other;
      }
    }
  }

  static int nesting(String? objectKey) {
    if (objectKey == null) return 0;
    var key = objectKey;
    if (key.characters.last == '/') {
      key = key.substring(0, objectKey.length - 1);
    }

    final count = key.split('/').length;
    final nesting = (count > 0) ? count - 1 : 0;

    if (nesting > 5) return 5;
    return nesting;
  }
}
