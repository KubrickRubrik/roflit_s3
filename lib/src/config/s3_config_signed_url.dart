import 'package:flutter/foundation.dart';

import '../constants.dart';
import '../entity/access.dart';
import '../entity/request.dart';
import '../entity/s3config_dto.dart';
import '../util/utility.dart';
import 's3_config_tool/s3_config_signed_tool.dart';
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
    required String defaultCanonicalQuerystring,
    required List<int> requestBody,
  }) {
    final validCanonicalUrl = S3Utility.getValidUrl(canonicalUrl);

    if (access.uselog) {
      debugPrint('Roflit: Canonical Url: $validCanonicalUrl\n');
    }

    final defaultHeaders = S3ConfigSignedTool.prepareHeaders(
      s3ConfigDto: s3ConfigDto,
      access: access,
      headers: headers,
    );

    if (access.uselog) {
      Utility.label(s3ConfigDto, canonicalUrl);
      debugPrint(
        'Roflit: Default Headers: ${defaultHeaders.entries.toString()}\n',
      );
    }

    final keyList = defaultHeaders.keys.map((e) => e.toLowerCase()).toList()
      ..sort();
    final xAmzSignedHeaderKeys = keyList.join(';');

    final credentialScope = Uri.encodeComponent(
      '${access.accessKeyId}/'
      '${s3ConfigDto.dateYYYYmmDD}/'
      '${access.region}/'
      '${Constants.service}/'
      '${Constants.aws4Request}',
    );

    if (access.uselog) {
      debugPrint('Roflit: Credential Scope: $credentialScope');
    }

    final canonicalQueryString = S3ConfigSignedTool.getCanonicalQueryString(
      s3ConfigDto: s3ConfigDto,
      canonicalQuerystring: defaultCanonicalQuerystring,
      credentialScope: credentialScope,
      xAmzSignedHeaderKeys: xAmzSignedHeaderKeys,
    );

    if (access.uselog) {
      debugPrint('Roflit: Canonical Query String: $canonicalQueryString');
    }

    final canonicalHeaders = S3ConfigSignedTool.getCanonicalHeaders(
      defaultHeaders: defaultHeaders,
    );

    if (access.uselog) {
      debugPrint('Roflit: Canonical Headers: $canonicalHeaders');
    }

    final canonicalRequest = S3ConfigSignedTool.getCanonicalRequest(
      requestType: requestType,
      validCanonicalUrl: validCanonicalUrl,
      newCanonicalQueryString: canonicalQueryString,
      canonicalHeaders: canonicalHeaders,
      signedHeaderKeys: xAmzSignedHeaderKeys,
    );

    if (access.uselog) {
      debugPrint('Roflit: Canonical Request $canonicalRequest');
    }

    final signature = S3ConfigSignedTool.getSignature(
      access: access,
      s3ConfigDto: s3ConfigDto,
      canonicalRequest: canonicalRequest,
    );

    if (access.uselog) {
      debugPrint('Roflit: Signature $signature');
    }

    final signedUrl = S3ConfigSignedTool.getRequest(
      access: access,
      canonicalUrl: canonicalUrl,
      canonicalQuerystring: defaultCanonicalQuerystring,
      credentialScope: credentialScope,
      s3ConfigDto: s3ConfigDto,
      xAmzSignedHeaders: xAmzSignedHeaderKeys,
      signature: signature,
    );

    if (access.uselog) {
      debugPrint('Roflit: Signed Url $signedUrl');
    }

    return RoflitRequest(
      uri: Uri.parse(signedUrl),
      headers: {},
      typeRequest: requestType,
      body: null,
    );
  }
}
