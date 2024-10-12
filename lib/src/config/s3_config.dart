import '../entity/access.dart';
import '../entity/request.dart';
import '../entity/s3config_dto.dart';
import '../util/utility.dart';
import 's3_config_default_url.dart';
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
    bool useSignedUrl = false,
  }) {
    final s3ConfigDto = S3ConfigDto.init(
      dateYYYYmmDD: Utility.dateYYYYmmDD,
      xAmzDateHeader: Utility.xAmzDateHeader,
      xAmzDateExpires: linkExpirationDate,
      bucket: bucketName.isNotEmpty ? '$bucketName.' : '',
      payloadHash: S3Utility.hashSha256(requestBody),
    );

    switch (useSignedUrl) {
      case true:
        return SignedS3Url.getRequest(
          s3ConfigDto: s3ConfigDto,
          access: access,
          canonicalUrl: canonicalRequest,
          requestType: requestType,
          headers: headers,
          defaultCanonicalQuerystring: canonicalQuerystring,
          requestBody: requestBody,
        );
      case false:
        return DefaultS3Url.getRequest(
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
}
