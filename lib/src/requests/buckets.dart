import '../config/s3_config.dart';
import '../entity/request.dart';
import 'parameters/bucket_parameters.dart';

/// Set of operations for working with cloud service buckets.
final class BucketRequests {
  final S3Config _s3Config;

  const BucketRequests(S3Config s3Config) : _s3Config = s3Config;

  /// The method returns the request data needed to get a list of available
  /// buckets for the service account in use.
  RoflitRequest get({
    Map<String, String> headers = const {},
    String queryParameters = '',
    Duration linkExpirationDate = const Duration(days: 30),
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.get;

    return _s3Config.preSigning(
      canonicalRequest: canonicalRequest,
      canonicalQuerystring: queryParameters,
      requestType: requestType,
      headers: headers,
      linkExpirationDate: linkExpirationDate,
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
    Duration linkExpirationDate = const Duration(days: 30),
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.get;

    return _s3Config.preSigning(
      canonicalRequest: canonicalRequest,
      bucketName: bucketName,
      canonicalQuerystring: queryParameters,
      requestType: requestType,
      headers: headers,
      linkExpirationDate: linkExpirationDate,
    );
  }

  /// The method returns the request data needed to create a bucket named `bucketName`.
  RoflitRequest create({
    required String bucketName,
    Map<String, String> headers = const {},
    Duration linkExpirationDate = const Duration(days: 30),
    bool useSignedUri = false,
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.put;

    return _s3Config.preSigning(
      canonicalRequest: canonicalRequest,
      bucketName: bucketName,
      requestType: requestType,
      headers: headers,
      linkExpirationDate: linkExpirationDate,
      useSignedUri: useSignedUri,
    );
  }

  /// The method returns the request data needed to delete bucket named `bucketName`.
  RoflitRequest delete({
    required String bucketName,
    Map<String, String> headers = const {},
    Duration linkExpirationDate = const Duration(days: 30),
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.delete;

    return _s3Config.preSigning(
      canonicalRequest: canonicalRequest,
      bucketName: bucketName,
      requestType: requestType,
      headers: headers,
      linkExpirationDate: linkExpirationDate,
    );
  }

  /// The method returns the request data needed to get a list of available objects in the bucket
  /// named `bucketName`. Pagination is used; in one request you can get a list of no longer than 1000 objects.
  /// If there are more objects, then you need to run several queries in a row.
  RoflitRequest getObjects({
    required String bucketName,
    Map<String, String> headers = const {},
    BucketListObjectParameters queryParameters = const BucketListObjectParameters.empty(),
    Duration linkExpirationDate = const Duration(days: 30),
  }) {
    const canonicalRequest = '/';
    const requestType = RequestType.get;

    return _s3Config.preSigning(
      canonicalRequest: canonicalRequest,
      bucketName: bucketName,
      canonicalQuerystring: queryParameters.queryString,
      requestType: requestType,
      headers: headers,
      linkExpirationDate: linkExpirationDate,
    );
  }
}
