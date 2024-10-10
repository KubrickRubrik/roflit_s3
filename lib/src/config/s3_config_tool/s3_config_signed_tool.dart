import '../../entity/access.dart';
import '../../entity/s3config_dto.dart';

abstract final class S3ConfigTool {
  static S3ConfigDto getSignatureHheaders({
    required RoflitAccess access,
    required Map<String, String> headers,
    required S3ConfigDto s3ConfigDto,
  }) {
    final defaultHeaders = {
      'host': '${s3ConfigDto.bucket}${access.host}',
      'x-amz-date': s3ConfigDto.xAmzDateHeader,
    };

    if (s3ConfigDto.payloadHash.isNotEmpty) {
      defaultHeaders.addAll({'x-amz-content-sha256': s3ConfigDto.payloadHash});
    }

    for (var key in headers.keys) {
      final titleKey = key.toLowerCase();
      final value = headers[key]!;
      defaultHeaders.addAll({titleKey: value});
    }

    if (!defaultHeaders.containsKey('content-type')) {
      defaultHeaders['content-type'] = 'application/x-amz-json-1.1';
    }

    return s3ConfigDto.setDefaultHeader(defaultHeaders);
  }
}
