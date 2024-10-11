import 'dart:convert';

import 'package:roflit_s3/src/constants.dart';

import '../../entity/access.dart';
import '../../entity/request.dart';
import '../../entity/s3config_dto.dart';
import 's3_sign.dart';

abstract final class S3ConfigSignedTool {
  static Map<String, String> getSignatureHeaders({
    required RoflitAccess access,
    required Map<String, String> headers,
    required S3ConfigDto s3ConfigDto,
  }) {
    final defaultHeaders = {
      'host': '${s3ConfigDto.bucket}${access.host}',
      // 'x-amz-date': s3ConfigDto.xAmzDateHeader,
    };

    // if (s3ConfigDto.payloadHash.isNotEmpty) {
    //   defaultHeaders.addAll({'x-amz-content-sha256': s3ConfigDto.payloadHash});
    // }

    // for (var key in headers.keys) {
    //   final titleKey = key.toLowerCase();
    //   final value = headers[key]!;
    //   defaultHeaders.addAll({titleKey: value});
    // }

    // if (!defaultHeaders.containsKey('content-type')) {
    //   defaultHeaders['content-type'] = 'application/x-amz-json-1.1';
    // }

    return defaultHeaders;
  }

  static String getCanonicalQueryString({
    required S3ConfigDto s3ConfigDto,
    required String canonicalQuerystring,
    required String credentialScope,
    required String xAmzSignedHeaders,
  }) {
    final defaultQuery = canonicalQuerystring.isNotEmpty ? '$canonicalQuerystring&' : '';

    final signedMap = {
      'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
      'X-Amz-Credential': credentialScope,
      'X-Amz-Date': s3ConfigDto.xAmzDateHeader,
      'X-Amz-Expires': s3ConfigDto.xAmzDateExpires.inSeconds.toString(),
      'X-Amz-SignedHeaders': xAmzSignedHeaders,
    };

    final rawCanonicalRequest = signedMap.entries.map((v) => '${v.key}=${v.value}').join('&');

    return '$defaultQuery$rawCanonicalRequest';
  }

  static String getCanonicalHeaders({
    required Map<String, String> defaultHeaders,
  }) {
    final canonicalHeaders = <String>[];
    defaultHeaders.forEach((key, value) {
      canonicalHeaders.add('$key:$value\n');
    });
    return (canonicalHeaders..sort()).join('');
  }

  static String getCanonicalRequest({
    required RequestType requestType,
    required String validCanonicalUrl,
    required String newCanonicalQueryString,
    required String canonicalHeaders,
    required String signedHeaderKeys,
  }) {
    return '${requestType.value}\n'
        '$validCanonicalUrl\n'
        '$newCanonicalQueryString\n'
        '$canonicalHeaders\n'
        '$signedHeaderKeys\n'
        'UNSIGNED-PAYLOAD';
  }

  static String getSignature({
    required RoflitAccess access,
    required S3ConfigDto s3ConfigDto,
    required String canonicalRequest,
  }) {
    final credentialScope =
        '${s3ConfigDto.dateYYYYmmDD}/${access.region}/${Constants.service}/${Constants.aws4Request}';

    final stringToSign = 'AWS4-HMAC-SHA256\n'
        '${s3ConfigDto.xAmzDateHeader}\n'
        '$credentialScope\n'
        '${S3Utility.hashSha256(utf8.encode(canonicalRequest))}';

    final signature = S3Utility.signSignature(
      secretKey: access.secretAccessKey,
      dateStamp: s3ConfigDto.dateYYYYmmDD,
      regionName: Constants.region,
      serviceName: Constants.service,
      stringToSign: stringToSign,
    );

    return signature;
  }

  static String getRequest({
    required RoflitAccess access,
    required String canonicalUrl,
    required String canonicalQuerystring,
    required String credentialScope,
    required S3ConfigDto s3ConfigDto,
    required String xAmzSignedHeaders,
    required String signature,
  }) {
    final queryString = canonicalQuerystring.isNotEmpty ? '?$canonicalQuerystring&' : '?';
    return 'https://${s3ConfigDto.bucket}${access.host}$canonicalUrl$queryString'
        'X-Amz-Algorithm=AWS4-HMAC-SHA256'
        '&X-Amz-Credential=$credentialScope'
        '&X-Amz-Date=${s3ConfigDto.xAmzDateHeader}'
        '&X-Amz-Expires=${s3ConfigDto.xAmzDateExpires.inSeconds.toString()}'
        '&X-Amz-SignedHeaders=${Uri.encodeComponent(xAmzSignedHeaders)}'
        '&X-Amz-Signature=$signature';
  }
}
