import 'dart:convert';

import '../../constants.dart';
import '../../entity/access.dart';
import '../../entity/request.dart';
import '../../entity/s3config_dto.dart';
import 's3_sign.dart';

abstract final class S3ConfigDefaultTool {
  static Map<String, String> getSignatureHeaders({
    required S3ConfigDto s3ConfigDto,
    required RoflitAccess access,
    required Map<String, String> headers,
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

    return defaultHeaders;
  }

  // Definition of a canonical default request.
  static String getCanonicalRequest({
    required S3ConfigDto s3ConfigDto,
    required RequestType requestType,
    required String canonicalRequest,
    required String canonicalQuerystring,
    required Map<String, String> defaultHeaders,
    required String signedHeaderKeys,
  }) {
    final canonicalHeaders = <String>[];
    defaultHeaders.forEach((key, value) {
      canonicalHeaders.add('$key:$value\n');
    });

    final canonicalHeadersString = (canonicalHeaders..sort()).join('');

    return '${requestType.value}\n'
        '$canonicalRequest\n'
        '$canonicalQuerystring\n'
        '$canonicalHeadersString\n'
        '$signedHeaderKeys\n'
        '${s3ConfigDto.payloadHash}';
  }

  static String getSignature({
    required S3ConfigDto s3ConfigDto,
    required RoflitAccess access,
    required Map<String, String> defaultHeaders,
    required String signedHeaderKeys,
    required String credentialScope,
    required String canonicalRequest,
  }) {
    final stringToSign = 'AWS4-HMAC-SHA256\n'
        '${s3ConfigDto.xAmzDateHeader}\n'
        '$credentialScope\n'
        '${S3Utility.hashSha256(utf8.encode(canonicalRequest))}';

    return S3Utility.signSignature(
      secretKey: access.secretAccessKey,
      dateStamp: s3ConfigDto.dateYYYYmmDD,
      regionName: Constants.region,
      serviceName: Constants.service,
      stringToSign: stringToSign,
    );
  }

  static Map<String, String> getHeaders({
    required S3ConfigDto s3ConfigDto,
    required RoflitAccess access,
    required Map<String, String> defaultHeaders,
    required String signedHeaderKeys,
    required String credentialScope,
    required String signature,
  }) {
    final authorization = 'AWS4-HMAC-SHA256 '
        'Credential=${access.accessKeyId}/$credentialScope, '
        'SignedHeaders=$signedHeaderKeys, '
        'Signature=$signature';

    return {
      'Accept': '*/*',
      'Authorization': authorization,
      ...defaultHeaders,
    };
  }
}
