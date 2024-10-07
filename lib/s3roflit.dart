library s3roflit;

import 'package:roflit_s3/src/constants.dart';
import 'package:roflit_s3/src/entity/access.dart';
import 'package:roflit_s3/src/requests/buckets.dart';
import 'package:roflit_s3/src/requests/objects.dart';

export 'package:roflit_s3/src/entity/request.dart';
export 'package:roflit_s3/src/entity/request_type.dart';
export 'package:roflit_s3/src/requests/parameters/bucket_parameters.dart';
export 'package:roflit_s3/src/requests/parameters/object_parameters.dart';

final class S3Roflit {
  final RoflitAccess _access;

  S3Roflit({
    required String accessKey,
    required String secretKey,
    required String host,
    required String region,
    bool useLog = false,
  }) : _access = RoflitAccess(
          accessKey: accessKey,
          secretKey: secretKey,
          host: host,
          region: region,
          useLog: useLog,
        );

  S3Roflit.yandex({
    required String accessKey,
    required String secretKey,
    String region = Constants.region,
    bool useLog = false,
  }) : _access = RoflitAccess(
          accessKey: accessKey,
          secretKey: secretKey,
          host: Constants.host,
          region: region,
          useLog: useLog,
        );

  String get host => 'https://${_access.host}';

  BucketRequests get buckets => BucketRequests(_access);

  ObjectRequests get objects => ObjectRequests(_access);
}
