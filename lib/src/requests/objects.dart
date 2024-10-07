import 'dart:convert';

import 'package:roflit_s3/src/config/s3_config.dart';
import 'package:roflit_s3/src/entity/access.dart';
import 'package:roflit_s3/src/entity/request.dart';
import 'package:roflit_s3/src/entity/request_type.dart';
import 'package:roflit_s3/src/requests/parameters/object_parameters.dart';

final class ObjectRequests {
  final RoflitAccess _access;

  ObjectRequests(RoflitAccess access) : _access = access;

  /// Returns an object from Object Storage.
  RoflitRequest get({
    required String bucketName,
    required String objectKey,
    Map<String, String> headers = const {},
    ObjectGetParameters queryParameters = const ObjectGetParameters.empty(),
  }) {
    final canonicalRequest = '/$bucketName/$objectKey';
    const requestType = RequestType.get;

    return S3Config.signing(
      access: _access,
      canonicalRequest: canonicalRequest,
      canonicalQuerystring: queryParameters.url,
      requestType: requestType,
      headers: headers,
    );
  }

  RoflitRequest delete({
    required String bucketName,
    required String objectKey,
    Map<String, String> headers = const {},
  }) {
    final canonicalRequest = '/$objectKey';
    const requestType = RequestType.delete;

    return S3Config.signing(
      access: _access,
      canonicalRequest: canonicalRequest,
      requestType: requestType,
      bucketName: bucketName,
      headers: headers,
    );
  }

  RoflitRequest upload({
    required String bucketName,
    required String objectKey,
    required List<int> body,
    required ObjectUploadHadersParameters headers,
  }) {
    final canonicalRequest = '/$objectKey';
    const requestType = RequestType.put;

    return S3Config.signing(
      access: _access,
      canonicalRequest: canonicalRequest,
      requestType: requestType,
      headers: headers.getHeaders,
      bucketName: bucketName,
      requestBody: body,
    );
  }

  RoflitRequest deleteMultiple({
    required String bucketName,
    required String body,
    DeleteObjectHeadersParameters headers = const DeleteObjectHeadersParameters(),
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.post;

    return S3Config.signing(
      access: _access,
      canonicalRequest: canonicalRequest,
      canonicalQuerystring: 'delete=true',
      requestType: requestType,
      bucketName: bucketName,
      headers: headers.getHeaders(inputStringDoc: utf8.encode(body)),
      requestBody: utf8.encode(body),
    );
  }
}
