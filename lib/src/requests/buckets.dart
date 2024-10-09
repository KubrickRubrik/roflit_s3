import '../config/s3_config.dart';
import '../entity/access.dart';
import '../entity/request.dart';
import 'parameters/bucket_parameters.dart';

/// Set of operations for working with cloud service buckets.
final class BucketRequests {
  final RoflitAccess _access;

  BucketRequests(RoflitAccess access) : _access = access;

  /// The method returns the request data needed to get a list of available
  /// buckets for the service account in use.
  RoflitRequest get({
    Map<String, String> headers = const {},
    String queryParameters = '',
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.get;

    return S3Config.signing(
      access: _access,
      canonicalRequest: canonicalRequest,
      canonicalQuerystring: queryParameters,
      requestType: requestType,
      headers: headers,
    );
  }

  /// The method returns the request data needed to:
  /// - Does the bucket exist?
  /// - Does the user have sufficient rights to access the bucket.
  /// The response can only contain general headers.
  RoflitRequest getMeta({
    required String bucketName,
    Map<String, String> headers = const {},
    String queryParameters = '',
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.get;

    return S3Config.signing(
      access: _access,
      canonicalRequest: canonicalRequest,
      bucketName: bucketName,
      canonicalQuerystring: queryParameters,
      requestType: requestType,
      headers: headers,
    );
  }

  /// The method returns the request data needed to create a bucket named `bucketName`.
  RoflitRequest create({
    required String bucketName,
    Map<String, String> headers = const {},
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.put;

    return S3Config.signing(
      access: _access,
      canonicalRequest: canonicalRequest,
      bucketName: bucketName,
      requestType: requestType,
      headers: headers,
    );
  }

  /// The method returns the request data needed to delete bucket named `bucketName`.
  RoflitRequest delete({
    required String bucketName,
    Map<String, String> headers = const {},
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.delete;

    return S3Config.signing(
      access: _access,
      canonicalRequest: canonicalRequest,
      bucketName: bucketName,
      requestType: requestType,
      headers: headers,
    );
  }

  /// The method returns the request data needed to get a list of available objects in the bucket
  /// named `bucketName`. Pagination is used; in one request you can get a list of no longer than 1000 objects.
  /// If there are more objects, then you need to run several queries in a row.
  RoflitRequest getObjects({
    required String bucketName,
    Map<String, String> headers = const {},
    BucketListObjectParameters queryParameters =
        const BucketListObjectParameters.empty(),
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.get;

    return S3Config.signing(
      access: _access,
      canonicalRequest: canonicalRequest,
      bucketName: bucketName,
      canonicalQuerystring: queryParameters.queryString,
      requestType: requestType,
      headers: headers,
    );
  }
}
