/// RoflitRequest contains the necessary list of properties required for the correct
/// execution of a request to the cloud service API.
///
/// Any http network request client will do to execute the request.
/// In the http client it is necessary to use the corresponding [RequestType] methods
final class RoflitRequest {
  final Uri _url;
  final Map<String, String> _headers;
  final RequestType _typeRequest;
  final Object? _body;

  RoflitRequest({
    required Uri uri,
    required Map<String, String> headers,
    required RequestType typeRequest,
    Object? body,
  })  : _url = uri,
        _headers = headers,
        _typeRequest = typeRequest,
        _body = body;

  Uri get url => _url;

  Map<String, String> get headers => _headers;

  RequestType get typeRequest => _typeRequest;

  Object? get body => _body;
}

/// RequestType contains the necessary set for specifying the corresponding request
/// method in the http client.
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
