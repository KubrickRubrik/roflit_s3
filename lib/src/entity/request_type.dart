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
