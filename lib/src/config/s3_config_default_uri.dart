import 'dart:developer';

import '../entity/access.dart';
import '../entity/request.dart';
import '../entity/s3config_dto.dart';
import 's3_config_tool/s3_config_default_tool.dart';

abstract final class DefaultS3Uri {
  const DefaultS3Uri();

  static RoflitRequest getRequest({
    required S3ConfigDto s3ConfigDto,
    required RoflitAccess access,
    required String canonicalUrl,
    required RequestType requestType,
    required Map<String, String> headers,
    required String canonicalQuerystring,
    required List<int> requestBody,
  }) {
    s3ConfigDto = S3ConfigDefaultTool.getSignatureHheaders(
      access: access,
      headers: headers,
      s3ConfigDto: s3ConfigDto,
    );
    if (access.useLog) log('S3 1.HEADERS FOR SIGNATURE: ${s3ConfigDto.defaultHeaders}');

    s3ConfigDto = S3ConfigDefaultTool.getCanonicalRequest(
      requestType: requestType,
      s3ConfigDto: s3ConfigDto,
      canonicalRequest: canonicalUrl,
      canonicalQuerystring: canonicalQuerystring,
    );
    if (access.useLog) log('S3 2.CANONICAL REQUEST: ${s3ConfigDto.canonicalRequest}');

    s3ConfigDto = S3ConfigDefaultTool.getSignature(
      access: access,
      s3ConfigDto: s3ConfigDto,
    );
    if (access.useLog) log('S3 3.SIGNATURE: ${s3ConfigDto.signature}');

    final s3Headers = S3ConfigDefaultTool.getHeaders(s3ConfigDto: s3ConfigDto);
    if (access.useLog) log('S3 4.HEADER: $s3Headers');
    final queryString = canonicalQuerystring.isNotEmpty ? '?$canonicalQuerystring' : '';

    final uri = Uri.parse(
      'https://${s3ConfigDto.bucket}${access.host}$canonicalUrl$queryString',
    );

    return RoflitRequest(
      uri: uri,
      headers: s3Headers,
      typeRequest: requestType,
      body: requestBody,
    );
  }
}
