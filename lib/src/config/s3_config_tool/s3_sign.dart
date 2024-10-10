import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../constants.dart';

abstract final class S3Utility {
  static String hashSha256(List<int> value) {
    return sha256.convert(value).toString();
  }

  static dynamic sign({required List<int> key, required String msg}) {
    return Hmac(sha256, key).convert(utf8.encode(msg));
  }

  static String getSignature({
    required String secretKey,
    required String dateStamp,
    required String regionName,
    required String serviceName,
    required String stringToSign,
  }) {
    final kDate = Hmac(sha256, utf8.encode('AWS4$secretKey')).convert(utf8.encode(dateStamp)).bytes;

    final kRegion = sign(key: kDate, msg: regionName).bytes;
    final kService = sign(key: kRegion, msg: serviceName).bytes;
    final kSigning = sign(key: kService, msg: Constants.aws4Request).bytes;
    return sign(key: kSigning, msg: stringToSign).toString();
  }
}
