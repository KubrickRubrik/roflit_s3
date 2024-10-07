final class RoflitAccess {
  final String keyIdentifier;
  final String secretKey;
  final String host;
  final String region;
  final bool useLog;

  const RoflitAccess({
    required this.keyIdentifier,
    required this.secretKey,
    required this.host,
    required this.region,
    required this.useLog,
  });
}
