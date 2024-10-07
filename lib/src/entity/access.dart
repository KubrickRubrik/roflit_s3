final class RoflitAccess {
  final String accessKey;
  final String secretKey;
  final String host;
  final String region;
  final bool useLog;

  const RoflitAccess({
    required this.accessKey,
    required this.secretKey,
    required this.host,
    required this.region,
    required this.useLog,
  });
}
