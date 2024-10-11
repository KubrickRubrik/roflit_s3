final class S3ConfigDto {
  final String dateYYYYmmDD;
  final String xAmzDateHeader;
  final Duration xAmzDateExpires;
  final String bucket;
  final String payloadHash;

  S3ConfigDto({
    required this.dateYYYYmmDD,
    required this.xAmzDateHeader,
    required this.xAmzDateExpires,
    required this.bucket,
    required this.payloadHash,
  });

  S3ConfigDto.init({
    required this.dateYYYYmmDD,
    required this.xAmzDateHeader,
    required this.bucket,
    required this.payloadHash,
    required this.xAmzDateExpires,
  });

  S3ConfigDto setDefaultHeader(Map<String, String> newDefaultHeaders) {
    return S3ConfigDto(
      dateYYYYmmDD: dateYYYYmmDD,
      xAmzDateHeader: xAmzDateHeader,
      xAmzDateExpires: xAmzDateExpires,
      bucket: bucket,
      payloadHash: payloadHash,
    );
  }

  S3ConfigDto setCanonicalRequest(String newCanonicalRequest) {
    return S3ConfigDto(
      dateYYYYmmDD: dateYYYYmmDD,
      xAmzDateHeader: xAmzDateHeader,
      xAmzDateExpires: xAmzDateExpires,
      bucket: bucket,
      payloadHash: payloadHash,
    );
  }
}
