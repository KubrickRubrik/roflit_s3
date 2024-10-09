import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

/// Сontains a possible list of available  object get parameters by default.
final class ObjectGetParameters {
  /// Sets the `Content-Type` response header.
  final bool responseContentType;

  /// Sets the `Content-Language` response header.
  final bool responseContentLanguage;

  /// Sets the `Expires` response header.
  final bool responseExpires;

  /// Sets the `Cache-Control` response header.
  final bool responseCacheControl;

  /// Sets the `Content-Disposition` response header.
  final bool responseContentDisposition;

  /// Sets the `Content-Encoding` response header.
  final bool responseContentEncoding;

  /// A reference to a specific version of an object.
  final String? versionId;

  const ObjectGetParameters({
    this.responseContentType = false,
    this.responseContentLanguage = false,
    this.responseExpires = false,
    this.responseCacheControl = false,
    this.responseContentDisposition = false,
    this.responseContentEncoding = false,
    this.versionId,
  });

  const ObjectGetParameters.empty()
      : responseContentType = false,
        responseContentLanguage = false,
        responseExpires = false,
        responseCacheControl = false,
        responseContentDisposition = false,
        responseContentEncoding = false,
        versionId = null;

  String get _responseContentType =>
      (responseContentType) ? '&response-content-type=true' : '';

  String get _responseContentLanguage =>
      (responseContentLanguage) ? '&response-content-language=true' : '';

  String get _responseExpires =>
      (responseExpires) ? '&response-expires=true' : '';

  String get _responseCacheControl =>
      (responseCacheControl) ? '&response-cache-control=true' : '';

  String get _responseContentDisposition =>
      (responseContentDisposition) ? '&response-content-disposition=true' : '';

  String get _responseContentEncoding =>
      (responseContentEncoding) ? '&response-content-encoding=true' : '';

  String get _versionId =>
      (versionId?.isNotEmpty == true) ? '&versionId=$versionId' : '';

  String get url =>
      '$_responseContentType$_responseContentLanguage$_responseExpires$_responseCacheControl$_responseContentDisposition$_responseContentEncoding$_versionId';
}

/// Contains a mandatory list of headers required to upload an object to cloud storage.
final class ObjectUploadHadersParameters {
  const ObjectUploadHadersParameters({
    required this.bodyBytes,
    this.xAmzStorageClass = ClassOfStorage.standard,
  });

  /// Cooler classes are intended for long-term storage of objects that are planned
  /// to be workedwith less frequently. The colder the storage, the cheaper it is to
  /// store data in it, but the more expensive it is to read and write it.
  /// If the header is not specified, then the object is saved in the
  /// storage set in the bucket settings.
  final ClassOfStorage xAmzStorageClass;

  /// Object Storage will calculate the MD5 for the stored object and if the calculated MD5
  /// does not match the one passed in the header, it will return an error.
  final List<int> bodyBytes;

  Map<String, String> get _xAmzStorageClass {
    return {'X-Amz-Storage-Class': xAmzStorageClass.name.toUpperCase()};
  }

  Map<String, String> get _contentMD5 {
    final digest = md5.convert(bodyBytes);
    return {'Content-MD5': base64Encode(digest.bytes)};
  }

  Map<String, String> get getHeaders => {..._xAmzStorageClass, ..._contentMD5};
}

/// Configuration of the storage (storage method) into which the object will be loaded.
enum ClassOfStorage {
  standard,
  cold,
  ice,
}

/// Contains a mandatory list of headers required to delete an object.
final class DeleteObjectHeadersParameters {
  final bool useXAmzBypassGovernanceRetention;

  const DeleteObjectHeadersParameters({
    this.useXAmzBypassGovernanceRetention = true,
  });

  Map<String, String> get _xAmzBypassGovernanceRetentionHeader {
    if (useXAmzBypassGovernanceRetention) {
      return {'X-Amz-Bypass-Governance-Retention': 'true'};
    }
    return {};
  }

  Map<String, String> _contentMD5({required List<int> input}) {
    Digest digest = md5.convert(input);
    return {'Content-MD5': base64Encode(digest.bytes)};
  }

  Map<String, String> _contentLength({required Uint8List input}) {
    final contentLength = input.length;
    return {'Content-Length': contentLength.toString()};
  }

  Map<String, String> getHeaders({required Uint8List inputStringDoc}) {
    return {
      ..._xAmzBypassGovernanceRetentionHeader,
      ..._contentMD5(input: inputStringDoc),
      ..._contentLength(input: inputStringDoc),
    };
  }
}
