// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:roflit_s3/roflit_s3.dart';
import 'package:roflit_s3_example/entity/result.dart';

void main() async {
  final operations = Operations();
  const bucketName = 'my-bucket';
  const objectName = 'my-object.jpg';
  // keyIdentifier and secretKey are properties of the key that is
  // created for the service account in the cloud storage console.
  final storage = RoflitS3(
    keyIdentifier: '************',
    secretKey: '****************',
    host: 'storage.yandexcloud.net',
    region: 'ru-central1',
  );

  // Create bucket
  final createBucketResponse = await operations.createBucket(storage, bucketName: bucketName);

  if (!createBucketResponse.sendOk) {
    log('Error: ${createBucketResponse.message}');
    return;
  }

  // Get bucket
  final getBucketsResponse = await operations.getBuckets(storage);

  if (!getBucketsResponse.sendOk) {
    log('Error: ${getBucketsResponse.message}');
    return;
  }
  log('Buckets ${getBucketsResponse.success}');

  // Uploading a file (object) to a bucket.
  final uploadObjectResponse = await operations.uploadObject(
    storage,
    bucketName: bucketName,
    objectName: objectName,
  );

  if (!uploadObjectResponse.sendOk) {
    log('Error: ${uploadObjectResponse.message}');
    return;
  }

  // Get objects
  final getObjectsResponse = await operations.getObjects(storage, bucketName: bucketName);

  if (!getObjectsResponse.sendOk) {
    log('Error: ${getObjectsResponse.message}');
    return;
  }
  log('Objects ${getObjectsResponse.success}');

  // Delete object
  final deleteObjectsResponse = await operations.deleteObject(
    storage,
    bucketName: bucketName,
    objectName: bucketName,
  );
  if (!deleteObjectsResponse.sendOk) {
    log('Error: ${deleteObjectsResponse.message}');
    return;
  }

  // Delete bucket
  final deleteBucketResponse = await operations.deleteBucket(storage, bucketName: bucketName);
  if (!deleteBucketResponse.sendOk) {
    log('Error: ${deleteBucketResponse.message}');
    return;
  }
}

final class Operations {
  final client = DioClient();

  Future<Result> createBucket(RoflitS3 storage, {required String bucketName}) async {
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
    final file = File('your/local/path/file.ext');

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
    final dto = storage.objects.delete(bucketName: bucketName, objectKey: objectName);
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
