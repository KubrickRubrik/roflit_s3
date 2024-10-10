import '../entity/access.dart';
import '../entity/request.dart';
import '../entity/s3config_dto.dart';
import '../util/utility.dart';
import 's3_config_default_uri.dart';
import 's3_config_signed_url.dart';
import 's3_config_tool/s3_sign.dart';

final class S3Config {
  final RoflitAccess access;

  const S3Config({required this.access});

  RoflitRequest preSigning({
    required String canonicalRequest,
    required RequestType requestType,
    required Map<String, String> headers,
    String canonicalQuerystring = '',
    List<int> requestBody = const [],
    String bucketName = '',
    Duration linkExpirationDate = const Duration(days: 30),
    bool useSignedUri = false,
  }) {
    final s3ConfigDto = S3ConfigDto.init(
      dateYYYYmmDD: Utility.dateYYYYmmDD,
      xAmzDateHeader: Utility.xAmzDateHeader,
      xAmzDateExpires: linkExpirationDate,
      bucket: bucketName.isNotEmpty ? '$bucketName.' : '',
      payloadHash: S3Utility.hashSha256(requestBody),
      // payloadHash: requestBody.isNotEmpty ? S3Utility.hashSha256(requestBody) : '',
    );

    switch (useSignedUri) {
      case true:
        return SignedS3Url.getRequest(
          s3ConfigDto: s3ConfigDto,
          access: access,
          canonicalUrl: canonicalRequest,
          requestType: requestType,
          headers: headers,
          canonicalQuerystring: canonicalQuerystring,
          requestBody: requestBody,
        );
      case false:
        return DefaultS3Uri.getRequest(
          s3ConfigDto: s3ConfigDto,
          access: access,
          canonicalUrl: canonicalRequest,
          requestType: requestType,
          headers: headers,
          canonicalQuerystring: canonicalQuerystring,
          requestBody: requestBody,
        );
    }
  }

  // static RoflitRequest signing({
  //   required RoflitAccess access,
  //   required String canonicalRequest,
  //   required RequestType requestType,
  //   required Map<String, String> headers,
  //   String canonicalQuerystring = '',
  //   List<int> requestBody = const [],
  //   String bucketName = '',
  //   Duration linkExpirationDate = const Duration(days: 30),
  // }) {
  //   log('S4 > ${bucketName}${canonicalRequest}');
  //   var s3ConfigDto = S3ConfigDto.init(
  //     dateYYYYmmDD: Utility.dateYYYYmmDD,
  //     xAmzDateHeader: Utility.xAmzDateHeader,
  //     xAmzDateExpires: linkExpirationDate,
  //     bucket: bucketName.isNotEmpty ? '$bucketName.' : '',
  //     payloadHash: S3Utility.hashSha256(requestBody),
  //   );
  //   //
  //   s3ConfigDto = S3Data.getSignatureHheaders(
  //     access: access,
  //     headers: headers,
  //     s3ConfigDto: s3ConfigDto,
  //   );
  //   if (access.useLog) log('S3 1.HEADERS FOR SIGNATURE: ${s3ConfigDto.defaultHeaders}');

  //   s3ConfigDto = S3Data.getCanonicalRequest(
  //     requestType: requestType,
  //     s3ConfigDto: s3ConfigDto,
  //     canonicalRequest: canonicalRequest,
  //     canonicalQuerystring: canonicalQuerystring,
  //   );
  //   if (access.useLog) log('S3 2.CANONICAL REQUEST: ${s3ConfigDto.canonicalRequest}');

  //   s3ConfigDto = S3Data.getSignature(
  //     access: access,
  //     s3ConfigDto: s3ConfigDto,
  //   );
  //   if (access.useLog) log('S3 3.SIGNATURE: ${s3ConfigDto.signature}');

  //   final s3Headers = S3Data.getHeaders(s3ConfigDto: s3ConfigDto);
  //   if (access.useLog) log('S3 4.HEADER: $s3Headers');
  //   final queryString = canonicalQuerystring.isNotEmpty ? '?$canonicalQuerystring' : '';

  //   final uri =
  //       Uri.parse('https://${s3ConfigDto.bucket}${access.host}$canonicalRequest$queryString');

  //   print('>>>> URI ${uri.toString()}');
  //   final signedUri = S3Data.getPreSignedUri(
  //     uri: uri,
  //     s3ConfigDto: s3ConfigDto,
  //   );

  //   return RoflitRequest(
  //     uri: uri,
  //     signedUri: signedUri,
  //     headers: s3Headers,
  //     typeRequest: requestType,
  //     body: requestBody,
  //   );
  // }
}
