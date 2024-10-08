class Result {
  final bool sendOk;
  final int? statusCode;
  final Object? success;
  final String? message;

  Result.success({
    required this.success,
    this.statusCode,
    this.message,
  }) : sendOk = (statusCode ?? 0) >= 200 && (statusCode ?? 0) < 300;

  Result.failuer({
    required this.message,
    this.statusCode,
    this.success,
  }) : sendOk = false;
}
