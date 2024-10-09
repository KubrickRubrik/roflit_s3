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

enum RequestType {
  get,
  put,
  delete,
  post;

  bool get isGet => this == get;
  bool get isPut => this == put;
  bool get isDelete => this == delete;
  bool get isPost => this == post;

  String get value => toString().split('.').last.toUpperCase();

  const RequestType();
}
