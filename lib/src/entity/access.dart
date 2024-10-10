final class RoflitAccess {
  final String accessKeyId;
  final String secretAccessKey;
  final String host;
  final String region;
  final bool useLog;

  const RoflitAccess({
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.host,
    required this.region,
    required this.useLog,
  });
}
