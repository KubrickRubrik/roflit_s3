import 'dart:developer';

import '../constants.dart';
import '../entity/access.dart';
import '../entity/request.dart';
import '../util/utility.dart';
import 's3_data.dart';
import 's3_util.dart';

abstract final class S3Config {
  static RoflitRequest signing({
    required RoflitAccess access,
    required String canonicalRequest,
    required RequestType requestType,
    required Map<String, String> headers,
    String canonicalQuerystring = '',
    List<int> requestBody = const [],
    String bucketName = '',
  }) {
    final dateYYYYmmDD = Utility.dateYYYYmmDD;
    final xAmzDateHeader = Utility.xAmzDateHeader;
    final bucket = bucketName.isNotEmpty ? '$bucketName.' : '';
    final payloadHash = S3Utility.hashSha256(requestBody);
    //
    final signatureHeaders = S3Data.getSignatureHheaders(
      access: access,
      headers: headers,
      xAmzDateHeader: xAmzDateHeader,
      bucket: bucket,
      payloadHash: payloadHash,
    );
    if (access.useLog) log('S3 1.HEADERS FOR SIGNATURE: $signatureHeaders');

    final canonicalS3Request = S3Data.getCanonicalRequest(
      requestType: requestType,
      payloadHash: payloadHash,
      signatureHeaders: signatureHeaders,
      canonicalRequest: canonicalRequest,
      canonicalQuerystring: canonicalQuerystring,
    );
    if (access.useLog) log('S3 2.CANONICAL REQUEST: $canonicalS3Request');

    final s3Signature = S3Data.getSignature(
      access: access,
      signatureHeaders: signatureHeaders,
      canonicalS3Request: canonicalS3Request,
      dateYYYYmmDD: dateYYYYmmDD,
      xAmzDateHeader: xAmzDateHeader,
    );
    if (access.useLog) log('S3 3.SIGNATURE: $s3Signature');

    final s3Headers = S3Data.getHeaders(
      signatureHeaders: signatureHeaders,
      signature: s3Signature,
    );
    if (access.useLog) log('S3 4.HEADER: $s3Headers');
    final queryString = canonicalQuerystring.isNotEmpty ? '?$canonicalQuerystring' : '';

    return RoflitRequest(
      url: Uri.parse('https://$bucket${Constants.host}$canonicalRequest$queryString'),
      headers: s3Headers,
      typeRequest: requestType,
      body: requestBody,
    );
  }
}
