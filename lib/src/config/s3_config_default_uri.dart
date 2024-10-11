import '../constants.dart';
import '../entity/access.dart';
import '../entity/request.dart';
import '../entity/s3config_dto.dart';
import 's3_config_tool/s3_config_default_tool.dart';
import 's3_config_tool/s3_sign.dart';

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
    final validCanonicalUrl = S3Utility.getValidUrl(canonicalUrl);

    final defaultHeaders = S3ConfigDefaultTool.prepareHeaders(
      s3ConfigDto: s3ConfigDto,
      access: access,
      headers: headers,
    );

    final keyList = defaultHeaders.keys.map((e) => e.toLowerCase()).toList()..sort();
    final signedHeaderKeys = keyList.join(';');

    final credentialScope = '${s3ConfigDto.dateYYYYmmDD}/'
        '${access.region}/'
        '${Constants.service}/'
        '${Constants.aws4Request}';

    final canonicalRequest = S3ConfigDefaultTool.getCanonicalRequest(
      requestType: requestType,
      s3ConfigDto: s3ConfigDto,
      canonicalRequest: validCanonicalUrl,
      canonicalQuerystring: canonicalQuerystring,
      defaultHeaders: defaultHeaders,
      signedHeaderKeys: signedHeaderKeys,
    );

    final signature = S3ConfigDefaultTool.getSignature(
      access: access,
      s3ConfigDto: s3ConfigDto,
      defaultHeaders: defaultHeaders,
      signedHeaderKeys: signedHeaderKeys,
      credentialScope: credentialScope,
      canonicalRequest: canonicalRequest,
    );

    final signedHeaders = S3ConfigDefaultTool.getHeaders(
      s3ConfigDto: s3ConfigDto,
      access: access,
      defaultHeaders: defaultHeaders,
      signedHeaderKeys: signedHeaderKeys,
      credentialScope: credentialScope,
      signature: signature,
    );

    final queryString = canonicalQuerystring.isNotEmpty ? '?$canonicalQuerystring' : '';

    final uri = Uri.parse(
      'https://${s3ConfigDto.bucket}${access.host}$validCanonicalUrl$queryString',
    );

    return RoflitRequest(
      uri: uri,
      headers: signedHeaders,
      typeRequest: requestType,
      body: requestBody,
    );
  }
}
