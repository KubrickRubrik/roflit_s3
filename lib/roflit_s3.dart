library s3roflit;

import 'src/constants.dart';
import 'src/entity/access.dart';
import 'src/requests/buckets.dart';
import 'src/requests/objects.dart';

export 'src/entity/request.dart';
export 'src/entity/request_type.dart';
export 'src/requests/parameters/bucket_parameters.dart';
export 'src/requests/parameters/object_parameters.dart';

final class RoflitS3 {
  final RoflitAccess _access;

  RoflitS3({
    required String keyIdentifier,
    required String secretKey,
    required String host,
    required String region,
    bool useLog = false,
  }) : _access = RoflitAccess(
          keyIdentifier: keyIdentifier,
          secretKey: secretKey,
          host: host,
          region: region,
          useLog: useLog,
        );

  RoflitS3.yandex({
    required String keyIdentifier,
    required String secretKey,
    String region = Constants.region,
    bool useLog = false,
  }) : _access = RoflitAccess(
          keyIdentifier: keyIdentifier,
          secretKey: secretKey,
          host: Constants.host,
          region: region,
          useLog: useLog,
        );

  String get host => 'https://${_access.host}';

  BucketRequests get buckets => BucketRequests(_access);

  ObjectRequests get objects => ObjectRequests(_access);
}
