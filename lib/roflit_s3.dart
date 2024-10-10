/// Fletch RoflitS3 package.
/// The class [RoflitS3] provide access to the REST AWS S3 Api features.
library roflitS3;

import 'src/config/s3_config.dart';
import 'src/constants.dart';
import 'src/entity/access.dart';
import 'src/requests/buckets.dart';
import 'src/requests/objects.dart';

export 'src/entity/request.dart';
export 'src/requests/parameters/bucket_parameters.dart';
export 'src/requests/parameters/object_parameters.dart';

/// The RoflitS3 instance sets up the configuration of the cloud storage service being
///  used and provides functionality for using its REST AWS S3 API.
final class RoflitS3 {
  final RoflitAccess _access;

  /// Configuration for arbitrary cloud storage compatible with REST AWS S3.
  RoflitS3({
    required String accessKeyId,
    required String secretAccessKey,
    required String host,
    required String region,
    bool useLog = false,
  }) : _access = RoflitAccess(
          accessKeyId: accessKeyId,
          secretAccessKey: secretAccessKey,
          host: host,
          region: region,
          useLog: useLog,
        );

  /// Configuration for Yandex Cloud service compatible with REST AWS S3.
  RoflitS3.yandex({
    required String keyIdentifier,
    required String secretKey,
    String region = Constants.region,
    bool useLog = false,
  }) : _access = RoflitAccess(
          accessKeyId: keyIdentifier,
          secretAccessKey: secretKey,
          host: Constants.host,
          region: region,
          useLog: useLog,
        );

  /// The cloud service host used.
  String get host => 'https://${_access.host}';

  /// An instance for working with bucket operations.
  BucketRequests get buckets => BucketRequests(S3Config(access: _access));

  /// An instance for working with objects operations.
  ObjectRequests get objects => ObjectRequests(S3Config(access: _access));
}
