import 'dart:convert';

import 'package:roflit_s3/s3roflit.dart';
import 'package:roflit_s3/src/config/s3_util.dart';
import 'package:roflit_s3/src/constants.dart';
import 'package:roflit_s3/src/entity/access.dart';

abstract final class S3Data {
  static Map<String, String> getSignatureHheaders({
    required RoflitAccess access,
    required Map<String, String> headers,
    required String xAmzDateHeader,
    String bucket = '',
    String payloadHash = '',
  }) {
    final defaultHeaders = {
      'host': '$bucket${access.host}',
      'x-amz-date': xAmzDateHeader,
    };

    if (payloadHash.isNotEmpty) {
      defaultHeaders.addAll({'x-amz-content-sha256': payloadHash});
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

  // Definition of a canonical query.
  static String getCanonicalRequest({
    required RequestType requestType,
    required String payloadHash,
    required Map<String, String> signatureHeaders,
    required String canonicalRequest,
    required String canonicalQuerystring,
  }) {
    final canonicalHeaders = <String>[];
    signatureHeaders.forEach((key, value) {
      canonicalHeaders.add('$key:$value\n');
    });

    final canonicalHeadersString = (canonicalHeaders..sort()).join('');

    final keyList = signatureHeaders.keys.map((e) => e.toLowerCase()).toList()..sort();
    final signedHeaderKeys = keyList.join(';');

    return '${requestType.value}\n'
        '$canonicalRequest\n'
        '$canonicalQuerystring\n'
        '$canonicalHeadersString\n'
        '$signedHeaderKeys\n'
        '$payloadHash';
  }

  static String getSignature({
    required RoflitAccess access,
    required Map<String, String> signatureHeaders,
    required String canonicalS3Request,
    required String dateYYYYmmDD,
    required String xAmzDateHeader,
  }) {
    const algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope =
        '$dateYYYYmmDD/${access.region}/${Constants.service}/${Constants.aws4Request}';

    final stringToSign = '$algorithm\n$xAmzDateHeader\n$credentialScope\n'
        '${S3Utility.hashSha256(utf8.encode(canonicalS3Request))}';

    final signature = S3Utility.getSignature(
      secretKey: access.secretKey,
      dateStamp: dateYYYYmmDD,
      regionName: Constants.region,
      serviceName: Constants.service,
      stringToSign: stringToSign,
    );

    final keyList = signatureHeaders.keys.toList()..sort();
    final signedHeaderKeys = keyList.join(';');

    return '$algorithm '
        'Credential=${access.accessKey}/$credentialScope, '
        'SignedHeaders=$signedHeaderKeys, '
        'Signature=$signature';
  }

  static Map<String, String> getHeaders({
    required Map<String, String> signatureHeaders,
    required String signature,
  }) {
    return {
      'Accept': '*/*',
      'Authorization': signature,
      ...signatureHeaders,
    };
  }
}
