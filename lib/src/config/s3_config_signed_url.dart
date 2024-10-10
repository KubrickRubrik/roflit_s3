import 'dart:developer';

import '../constants.dart';
import '../entity/access.dart';
import '../entity/request.dart';
import '../entity/s3config_dto.dart';
import 's3_config_tool/s3_config_default_tool.dart';
import 's3_config_tool/s3_sign.dart';

abstract final class SignedS3Url {
  final S3ConfigDto s3ConfigDto;

  const SignedS3Url(this.s3ConfigDto);

  static RoflitRequest getRequest({
    required S3ConfigDto s3ConfigDto,
    required RoflitAccess access,
    required String canonicalUrl,
    required RequestType requestType,
    required Map<String, String> headers,
    required String canonicalQuerystring,
    required List<int> requestBody,
  }) {
    //! 1 Формирование заголовков
    s3ConfigDto = S3ConfigDefaultTool.getSignatureHheaders(
      access: access,
      headers: headers,
      s3ConfigDto: s3ConfigDto,
    );
    if (access.useLog) log('S3 1.HEADERS FOR SIGNATURE: ${s3ConfigDto.defaultHeaders}');

    //! 2 CanonicalQueryString
    const xAmzAlgorithm = 'AWS4-HMAC-SHA256';
    final credentialScope =
        '${access.accessKeyId}/${s3ConfigDto.dateYYYYmmDD}/${access.region}/${Constants.service}/${Constants.aws4Request}';

    final keyList = s3ConfigDto.defaultHeaders.keys.map((e) => e.toLowerCase()).toList()..sort();
    final xAmzSignedHeaders = keyList.join(';');

    final defaultQuery = canonicalQuerystring.isNotEmpty ? '$canonicalQuerystring&' : '?';

    final signedMap = {
      'X-Amz-Algorithm': xAmzAlgorithm,
      'X-Amz-Credential': credentialScope,
      'X-Amz-Date': s3ConfigDto.xAmzDateHeader,
      'X-Amz-Expires': s3ConfigDto.xAmzDateExpires.inSeconds.toString(),
      'X-Amz-SignedHeaders': xAmzSignedHeaders,
    };

    final canonicalRequest = signedMap.entries.map((v) => '${v.key}=${v.value}').join('&');

    final newCanonicalQueryString = '$defaultQuery$canonicalRequest';

    //! 3 CanonicalHeaders
    final canonicalHeaders = <String>[];
    s3ConfigDto.defaultHeaders.forEach((key, value) {
      canonicalHeaders.add('$key:$value\n');
    });
    final canonicalHeadersString = (canonicalHeaders..sort()).join('');

    //! 4 SignedHeaders
    final keyListHeaders = s3ConfigDto.defaultHeaders.keys.map((e) => e.toLowerCase()).toList()
      ..sort();
    final signedHeaderKeys = keyListHeaders.join(';');

    //! 5 Канонический запрос
    final request = '${requestType.value}\n'
        '$canonicalRequest\n'
        '$newCanonicalQueryString\n'
        '$canonicalHeadersString\n'
        '$signedHeaderKeys\n'
        'UNSIGNED-PAYLOAD';

    final signature = S3Utility.getSignature(
      secretKey: access.secretAccessKey,
      dateStamp: s3ConfigDto.dateYYYYmmDD,
      regionName: Constants.region,
      serviceName: Constants.service,
      stringToSign: request,
    );

    //! Строка запроса
    final queryString = canonicalQuerystring.isNotEmpty ? '?$canonicalQuerystring&' : '?';
    final rawUri = 'https://${s3ConfigDto.bucket}${access.host}$canonicalUrl$queryString'
        'X-Amz-Algorithm=AWS4-HMAC-SHA256'
        '&X-Amz-Credential=${Uri.encodeComponent(credentialScope)}'
        '&X-Amz-Date=${s3ConfigDto.xAmzDateHeader}'
        '&X-Amz-Expires=${s3ConfigDto.xAmzDateExpires.inSeconds.toString()}'
        '&X-Amz-SignedHeaders=${Uri.encodeComponent(xAmzSignedHeaders)}'
        '&X-Amz-Signature=$signature';

    return RoflitRequest(
      uri: Uri.parse(rawUri),
      headers: {},
      typeRequest: requestType,
      body: null,
    );
  }
}
