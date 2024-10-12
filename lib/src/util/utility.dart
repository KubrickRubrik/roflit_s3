import 'package:flutter/foundation.dart';

import '../entity/s3config_dto.dart';
import './extension.dart';

abstract final class Utility {
  static String get dateYYYYmmDD => DateTime.now().toUtc().yyyyMMdd;
  static String get xAmzDateHeader => DateTime.now().toUtc().xAmzDate;

  static void label(S3ConfigDto s3ConfigDto, String canonicalUrl) {
    final bucketName = s3ConfigDto.bucket.split('.').first;
    final wrap =
        List.generate('$bucketName$canonicalUrl'.length, (i) => '=').join();
    debugPrint(
      '=======================$wrap=======================\n'
      '====================== $bucketName$canonicalUrl ======================\n'
      '=======================$wrap=======================\n',
    );
  }
}
