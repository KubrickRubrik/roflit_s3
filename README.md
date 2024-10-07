# Roflit S3

An easy-to-use REST AWS S3 package for working with Yandex Cloud storage services.

## Installing

```yaml
dependencies:
  roflit_s3: <latest_version>
```

## Import

```dart
import 'package:roflit_s3/roflit_s3.dart';
```

## Usage

To use Roflit S3, you need to complete three steps:

1.  Create a RoflitS3 instance by passing the parameters of the cloud storage account to it.
2.  Form the request data for the operation on buckets or objects.
3.  Pass the request data to your request client.

## Let's look at an example:

Step 1

```dart
// How to get storageAccount parameters can be found in the documentation
// of the cloud service you are using and the service management console.
final storage = RoflitS3(
          keyIdentifier: cloudStorageServiceAccount.keyIdentifier,
          secretKey: cloudStorageServiceAccount.secretKey,
          host: cloudStorage.host,
          region: cloudStorage.region,
       );
// If this is your first time using the cloud service, you will most likely also need:
// 1. Create a service account;
// 2. Assign roles to it;
// 3. Create a secret static key for it and save its details (keyIdentifier and secretKey).
```

Step 2

```dart
   // Generate request data for all buckets from cloud.
   final requestBucketsData = storage.buckets.get();
   // Removing a bucket from cloud.
   final bucketDeleteRequestData = storage.buckets.delete(bucketName: 'bucketName');
```

Step 3

```dart
   Response<dynamic>? response;
   switch(requestData.typeRequest){
        case RequestType.get:
                final response = await _dio.get<dynamic>(
                requestData.url.toString(),
                options: Options(headers: requestData.headers),
                ).timeout(const Duration(seconds: 10));
        case RequestType.delete:
                final response = await _dio.delete<dynamic>(
                requestData.url.toString(),
                options: Options(headers: requestData.headers),
                );
        ...
   }
```

## Contributions

If you encounter any problem or the library is missing a feature feel free to open an issue. Feel
free to fork, improve the package and make pull request.
