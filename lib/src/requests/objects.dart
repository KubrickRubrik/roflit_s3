import 'dart:convert';

import '../config/s3_config.dart';
import '../entity/request.dart';
import 'parameters/object_parameters.dart';

/// Set of operations for working with cloud service objects.
final class ObjectRequests {
  final S3Config _s3Config;

  const ObjectRequests(S3Config s3Config) : _s3Config = s3Config;

  /// The method returns the request data needed to retrieve an object named `objectKey`
  /// in a bucket named `bucketName`.
  RoflitRequest get({
    required String bucketName,
    required String objectKey,
    Map<String, String> headers = const {},
    ObjectGetParameters queryParameters = const ObjectGetParameters.empty(),
    Duration linkExpirationDate = const Duration(days: 30),
    bool useSignedUri = false,
  }) {
    final canonicalRequest = '/$objectKey';
    const requestType = RequestType.get;

    return _s3Config.preSigning(
      bucketName: bucketName,
      canonicalRequest: canonicalRequest,
      canonicalQuerystring: queryParameters.url,
      requestType: requestType,
      headers: headers,
      linkExpirationDate: linkExpirationDate,
      useSignedUri: useSignedUri,
    );
  }

  /// The method returns the request data needed to delete an object named `objectKey` in
  /// a bucket named `bucketName`.
  RoflitRequest delete({
    required String bucketName,
    required String objectKey,
    Map<String, String> headers = const {},
    Duration linkExpirationDate = const Duration(days: 30),
  }) {
    final canonicalRequest = '/$objectKey';
    const requestType = RequestType.delete;

    return _s3Config.preSigning(
      canonicalRequest: canonicalRequest,
      requestType: requestType,
      bucketName: bucketName,
      headers: headers,
      linkExpirationDate: linkExpirationDate,
    );
  }

  /// The method returns the request data needed to upload the file and create an object
  /// named `objectKey` in a bucket named `bucketName`.
  RoflitRequest upload({
    required String bucketName,
    required String objectKey,
    required List<int> body,
    required ObjectUploadHadersParameters headers,
    Duration linkExpirationDate = const Duration(days: 30),
    bool useSignedUri = false,
  }) {
    final canonicalRequest = '/$objectKey';
    const requestType = RequestType.put;

    return _s3Config.preSigning(
      canonicalRequest: canonicalRequest,
      requestType: requestType,
      headers: headers.getHeaders,
      bucketName: bucketName,
      requestBody: body,
      linkExpirationDate: linkExpirationDate,
      useSignedUri: useSignedUri,
    );
  }

  /// The method returns the request data needed to delete multiple objects in a single request.
  /// To do this, you need to create an XML document with a list of keys of the objects to be deleted.
  /// ```dart
  /// '<?xml version="1.0" encoding="UTF-8"?>
  ///   <Delete>
  ///     <Quiet>true</Quiet>
  ///     <Object><Key>$keyNameObject_1</Key></Object>
  ///     <Object><Key>$keyNameObject_2</Key></Object>
  ///     <Object><Key>$keyNameObject_3</Key></Object>
  ///   </Delete>'
  /// ```
  RoflitRequest deleteMultiple({
    required String bucketName,
    required String body,
    DeleteObjectHeadersParameters headers = const DeleteObjectHeadersParameters(),
    Duration linkExpirationDate = const Duration(days: 30),
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.post;

    return _s3Config.preSigning(
      canonicalRequest: canonicalRequest,
      canonicalQuerystring: 'delete=true',
      requestType: requestType,
      bucketName: bucketName,
      headers: headers.getHeaders(inputStringDoc: utf8.encode(body)),
      requestBody: utf8.encode(body),
      linkExpirationDate: linkExpirationDate,
    );
  }
}
