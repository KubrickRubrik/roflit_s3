import '../constants.dart';
import '../entity/access.dart';
import '../entity/request.dart';
import '../entity/s3config_dto.dart';
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
    //! 1
    final validCanonicalUrl = S3Utility.getValidUrl(canonicalUrl);

    //! 2
    final defaultHeaders = S3ConfigSignedTool.getSignatureHeaders(
      access: access,
      headers: headers,
      s3ConfigDto: s3ConfigDto,
    );

    //! 3
    final keyList = defaultHeaders.keys.map((e) => e.toLowerCase()).toList()..sort();
    final xAmzSignedHeaders = keyList.join(';');

    //! 4
    final credentialScope = Uri.encodeComponent(
      '${access.accessKeyId}/'
      '${s3ConfigDto.dateYYYYmmDD}/'
      '${access.region}/'
      '${Constants.service}/'
      '${Constants.aws4Request}',
    );

    //! 4
    final canonicalQueryString = S3ConfigSignedTool.getCanonicalQueryString(
      s3ConfigDto: s3ConfigDto,
      canonicalQuerystring: defaultCanonicalQuerystring,
      credentialScope: credentialScope,
      xAmzSignedHeaders: xAmzSignedHeaders,
    );

    //! 5
    final canonicalHeaders = S3ConfigSignedTool.getCanonicalHeaders(
      defaultHeaders: defaultHeaders,
    );

    //! 6
    final keyListHeaders = defaultHeaders.keys.map((e) => e.toLowerCase()).toList()..sort();
    final signedHeaderKeys = keyListHeaders.join(';');

    //! 7
    final canonicalRequest = S3ConfigSignedTool.getCanonicalRequest(
      requestType: requestType,
      validCanonicalUrl: validCanonicalUrl,
      newCanonicalQueryString: canonicalQueryString,
      canonicalHeaders: canonicalHeaders,
      signedHeaderKeys: signedHeaderKeys,
    );

    //! 8
    final signature = S3ConfigSignedTool.getSignature(
      access: access,
      s3ConfigDto: s3ConfigDto,
      canonicalRequest: canonicalRequest,
    );

    //! 9
    final signedUrl = S3ConfigSignedTool.getRequest(
      access: access,
      canonicalUrl: canonicalUrl,
      canonicalQuerystring: defaultCanonicalQuerystring,
      credentialScope: credentialScope,
      s3ConfigDto: s3ConfigDto,
      xAmzSignedHeaders: xAmzSignedHeaders,
      signature: signature,
    );

    return RoflitRequest(
      uri: Uri.parse(signedUrl),
      headers: {},
      typeRequest: requestType,
      body: null,
    );
  }
}
