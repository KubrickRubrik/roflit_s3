import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:roflit_s3/roflit_s3.dart';
import 'package:roflit_s3_example/entity/object.dart';
import 'package:roflit_s3_example/entity/result.dart';
import 'package:xml2json/xml2json.dart';

import 'entity/bucket.dart';
import 'util/extension_converter.dart';

void main() async {
  const bucketName = 'my-bucket';
  const objectName = 'my-object';
  const host = 'storage.yandexcloud.net';

  final serializer = Serializer(host: host);
  final operations = Operations();

  // keyIdentifier and secretKey are properties of the key that is
  // created for the service account in the cloud storage console.
  final storage = RoflitS3(
    accessKeyId: '************',
    secretAccessKey: '****************',
    host: host,
    region: 'ru-central1',
  );

  // Create bucket
  final createBucketResponse = await operations.createBucket(
    storage,
    bucketName: bucketName,
  );

  if (!createBucketResponse.isSuccess) {
    debugPrint('Error: ${createBucketResponse.message}');
    return;
  }

  // Get bucket
  final getBucketsResponse = await operations.getBuckets(storage);

  if (!getBucketsResponse.isSuccess) {
    debugPrint('Error: ${getBucketsResponse.message}');
    return;
  }
  final buckets = serializer.buckets(getBucketsResponse.success);
  debugPrint('Buckets $buckets');

  // Uploading a file (object) to a bucket.
  final uploadObjectResponse = await operations.uploadObject(
    storage,
    bucketName: bucketName,
    objectName: objectName,
  );

  if (!uploadObjectResponse.isSuccess) {
    debugPrint('Error: ${uploadObjectResponse.message}');
    return;
  }

  // Get objects
  final getObjectsResponse = await operations.getObjects(
    storage,
    bucketName: bucketName,
  );

  if (!getObjectsResponse.isSuccess) {
    debugPrint('Error: ${getObjectsResponse.message}');
    return;
  }
  final objects = serializer.objects(getObjectsResponse.success);
  debugPrint('Objects $objects');

  // Delete object
  final deleteObjectsResponse = await operations.deleteObject(
    storage,
    bucketName: bucketName,
    objectName: bucketName,
  );
  if (!deleteObjectsResponse.isSuccess) {
    debugPrint('Error: ${deleteObjectsResponse.message}');
    return;
  }

  // Delete bucket
  final deleteBucketResponse =
      await operations.deleteBucket(storage, bucketName: bucketName);
  if (!deleteBucketResponse.isSuccess) {
    debugPrint('Error: ${deleteBucketResponse.message}');
    return;
  }
}

final class Operations {
  final client = DioClient();

  Future<Result> createBucket(RoflitS3 storage,
      {required String bucketName}) async {
    final dto = storage.buckets.create(
      bucketName: bucketName,
      headers: {'X-Amz-Acl': 'public-read'}, // or 'bucket-owner-full-control'
    );

    return client.send(dto);
  }

  Future<Result> getBuckets(RoflitS3 storage) async {
    final dto = storage.buckets.get();
    return client.send(dto);
  }

  Future<Result> uploadObject(
    RoflitS3 storage, {
    required String bucketName,
    required String objectName,
  }) async {
    final file = File('your/local-path/file.ext');

    final dto = storage.objects.upload(
      bucketName: bucketName,
      objectKey: objectName,
      headers: ObjectUploadHadersParameters(bodyBytes: file.readAsBytesSync()),
      body: file.readAsBytesSync(),
    );

    return client.send(dto);
  }

  Future<Result> getObjects(
    RoflitS3 storage, {
    required String bucketName,
  }) async {
    final dto = storage.buckets.getObjects(bucketName: bucketName);
    return client.send(dto);
  }

  Future<Result> deleteObject(
    RoflitS3 storage, {
    required String bucketName,
    required String objectName,
  }) async {
    final dto =
        storage.objects.delete(bucketName: bucketName, objectKey: objectName);
    return client.send(dto);
  }

  Future<Result> deleteBucket(
    RoflitS3 storage, {
    required String bucketName,
  }) async {
    final dto = storage.buckets.delete(bucketName: bucketName);
    return client.send(dto);
  }
}

final class DioClient {
  final _dio = Dio();

  Future<Result> send(
    RoflitRequest client,
  ) async {
    Response<dynamic>? response;
    try {
      switch (client.typeRequest) {
        case RequestType.get:
          response = await _dio
              .get<dynamic>(
                client.url.toString(),
                options: Options(
                  headers: client.headers,
                ),
              )
              .timeout(const Duration(seconds: 10));

        case RequestType.put:
          response = await _dio.put(
            client.url.toString(),
            options: Options(headers: client.headers),
            data: client.body,
            onSendProgress: (count, total) {
              log('S3 PUT $count / $total');
            },
          );
        case RequestType.delete:
          response = await _dio.delete(
            client.url.toString(),
            options: Options(
              headers: client.headers,
            ),
          );
        case RequestType.post:
          response = await _dio.post(
            client.url.toString(),
            options: Options(
              headers: client.headers,
            ),
            data: client.body,
          );
      }

      final statusCode = response.statusCode ?? 400;

      if (statusCode < 200 || statusCode >= 300) {
        return Result.failuer(
          statusCode: response.statusCode,
          message: response.statusMessage,
          success: response.data,
        );
      } else {
        return Result.success(
          statusCode: response.statusCode,
          success: response.data,
        );
      }
    } catch (e, s) {
      return Result.failuer(
        statusCode: 400,
        message: 'Runtime error $e $s',
      );
    }
  }
}

final class Serializer {
  final String host;

  Serializer({required this.host});

  final _parser = Xml2Json();

  List<BucketEntity> buckets(Object? value) {
    try {
      _parser.parse(value as String);
      final json = jsonDecode(_parser.toParker());
      final document = json['ListAllMyBucketsResult'];
      final buckets = document['Buckets']['Bucket'] as List?;

      final newBuckets = List.generate(buckets?.length ?? 0, (index) {
        final bucket = buckets![index];
        return BucketEntity(
          bucket: bucket['Name'],
          creationDate: bucket['CreationDate'],
        );
      });

      return newBuckets;
    } catch (e) {
      return [];
    }
  }

  List<ObjectEntity> objects(Object? value) {
    try {
      _parser.parse(value as String);
      final json = jsonDecode(_parser.toParker());
      final document = json['ListBucketResult'];

      final bucket = document['Name'];
      final objects = document['Contents'] as List?;

      final newObjects = List.generate(objects?.length ?? 0, (index) {
        final object = objects![index];
        return ObjectEntity(
          objectKey: object['Key'],
          bucket: bucket,
          type: FormatConverter.converter(object['Key']),
          nesting: FormatConverter.nesting(object['Key']),
          remotePath: '$host/$bucket/${object['Key']}',
          size: int.tryParse(object['Size']) ?? 0,
          lastModified: object['LastModified'],
        );
      });

      return newObjects;
    } catch (e) {
      return [];
    }
  }
}
