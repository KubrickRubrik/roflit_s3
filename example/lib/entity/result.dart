class Result {
  final bool isSuccess;
  final int? statusCode;
  final Object? success;
  final String? message;

  Result.success({
    required this.success,
    this.statusCode,
    this.message,
  }) : isSuccess = (statusCode ?? 0) >= 200 && (statusCode ?? 0) < 300;

  Result.failuer({
    required this.message,
    this.statusCode,
    this.success,
  }) : isSuccess = false;
}
