import 'dart:convert';

import '../../constants.dart';
import '../../entity/access.dart';
import '../../entity/request.dart';
import '../../entity/s3config_dto.dart';
import 's3_sign.dart';

abstract final class S3ConfigDefaultTool {
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

  // Definition of a canonical default request.
  static S3ConfigDto getCanonicalRequest({
    required RequestType requestType,
    required S3ConfigDto s3ConfigDto,
    required String canonicalRequest,
    required String canonicalQuerystring,
  }) {
    final canonicalHeaders = <String>[];
    s3ConfigDto.defaultHeaders.forEach((key, value) {
      canonicalHeaders.add('$key:$value\n');
    });

    final canonicalHeadersString = (canonicalHeaders..sort()).join('');

    final keyList = s3ConfigDto.defaultHeaders.keys.map((e) => e.toLowerCase()).toList()..sort();
    final signedHeaderKeys = keyList.join(';');

    final newCanonicalRequest = '${requestType.value}\n'
        '$canonicalRequest\n'
        '$canonicalQuerystring\n'
        '$canonicalHeadersString\n'
        '$signedHeaderKeys\n'
        '${s3ConfigDto.payloadHash}';

    return s3ConfigDto.setCanonicalRequest(newCanonicalRequest);
  }

  static S3ConfigDto getSignature({
    required RoflitAccess access,
    required S3ConfigDto s3ConfigDto,
  }) {
    const algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope =
        '${s3ConfigDto.dateYYYYmmDD}/${access.region}/${Constants.service}/${Constants.aws4Request}';

    final stringToSign = '$algorithm\n${s3ConfigDto.xAmzDateHeader}\n$credentialScope\n'
        '${S3Utility.hashSha256(utf8.encode(s3ConfigDto.canonicalRequest))}';

    final signature = S3Utility.getSignature(
      secretKey: access.secretAccessKey,
      dateStamp: s3ConfigDto.dateYYYYmmDD,
      regionName: Constants.region,
      serviceName: Constants.service,
      stringToSign: stringToSign,
    );

    final keyList = s3ConfigDto.defaultHeaders.keys.toList()..sort();
    final headers = keyList.join(';');

    return s3ConfigDto.setSignature(
      S3ConfigSignatureDto(
        algorithm: algorithm,
        credential: '${access.accessKeyId}/$credentialScope',
        signedHeaders: headers,
        signature: signature,
      ),
    );
  }

  static Map<String, String> getHeaders({
    required S3ConfigDto s3ConfigDto,
  }) {
    final authorization = '${s3ConfigDto.signature.algorithm} '
        'Credential=${s3ConfigDto.signature.credential}, '
        'SignedHeaders=${s3ConfigDto.signature.signedHeaders}, '
        'Signature=${s3ConfigDto.signature.signature}';

    return {
      'Accept': '*/*',
      'Authorization': authorization,
      ...s3ConfigDto.defaultHeaders,
    };
  }
}
