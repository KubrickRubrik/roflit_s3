# Roflit S3

Flutter package for easy work with REST AWS S3.

## Installing

```yaml
dependencies:
  roflit_s3: <latest_version>
```

## Import

```dart
import 'package:roflit_s3/roflit_s3.dart';
```

## Getting Started

To use Roflit S3, you need to complete three steps:

1.  Create a RoflitS3 instance by passing the parameters of the cloud storage account to it.
2.  Form the request data for the operation on buckets or objects.
3.  Pass the request data to your request client.

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
// If this is your first time using the cloud service, you will
// most likely also need:
// 1. Create an account on your cloud storage;
// 2. Assign roles to it (access rights);
// 3. Create a secret static key for it and save its
//    details (accessKeyId and secretAccessKey).
```

Step 2

```dart
   // Generate query data to select data from the cloud.
   final requestBucketsData = storage.buckets.get();
   // Removing a bucket from cloud.
   final requestBucketObjectsData = storage.buckets.getObjects(
      bucketName: 'bucketName',
    );
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

To read bucket and object data, you will need to parse XML or convert XML to Json. More details in the example.

## Read/Download object:

There are two ways to read/download an object from a private storage:

1. Signed request.

```dart
 // Generate signed request data.
 final object = storage.objects.get(
      bucketName: 'bucketName',
      objectKey: 'objectKey',
    );
 // Use url and headers in your widgets.
 Image.network(
    object.url.toString(),
    headers: object.headers,
 )
```

2. Signed link.

```dart
 // Generate signed link data.
 final object = storage.objects.get(
      bucketName: 'bucketName',
      objectKey: 'objectKey',
      useSignedUrl: true,
    );
 // Use only url.
 Image.network(
    object.url.toString(),
 )
```

## Contributions

If you encounter any problem or the library is missing a feature feel free to open an issue. Feel
free to fork, improve the package and make pull request.
