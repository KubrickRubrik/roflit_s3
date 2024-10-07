import 'package:roflit_s3/src/entity/request_type.dart';

final class RoflitRequest {
  final Uri _url;
  final Map<String, String> _headers;
  final RequestType _typeRequest;
  final Object? _body;

  RoflitRequest({
    required Uri url,
    required Map<String, String> headers,
    required RequestType typeRequest,
    Object? body,
  })  : _url = url,
        _headers = headers,
        _typeRequest = typeRequest,
        _body = body;

  Uri get url => _url;

  Map<String, String> get headers => _headers;

  RequestType get typeRequest => _typeRequest;

  Object? get body => _body;
}
