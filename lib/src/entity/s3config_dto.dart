final class S3ConfigDto {
  final String dateYYYYmmDD;
  final String xAmzDateHeader;
  final Duration xAmzDateExpires;
  final String bucket;
  final String payloadHash;
  final Map<String, String> defaultHeaders;
  final String canonicalRequest;

  final S3ConfigSignatureDto signature;

  S3ConfigDto({
    required this.dateYYYYmmDD,
    required this.xAmzDateHeader,
    required this.xAmzDateExpires,
    required this.bucket,
    required this.payloadHash,
    required this.defaultHeaders,
    required this.canonicalRequest,
    required this.signature,
  });

  S3ConfigDto.init({
    required this.dateYYYYmmDD,
    required this.xAmzDateHeader,
    required this.bucket,
    required this.payloadHash,
    required this.xAmzDateExpires,
  })  : defaultHeaders = const {},
        canonicalRequest = '',
        signature = const S3ConfigSignatureDto.empty();

  S3ConfigDto setDefaultHeader(Map<String, String> newDefaultHeaders) {
    return S3ConfigDto(
      dateYYYYmmDD: dateYYYYmmDD,
      xAmzDateHeader: xAmzDateHeader,
      xAmzDateExpires: xAmzDateExpires,
      bucket: bucket,
      payloadHash: payloadHash,
      defaultHeaders: newDefaultHeaders,
      canonicalRequest: canonicalRequest,
      signature: signature,
    );
  }

  S3ConfigDto setCanonicalRequest(String newCanonicalRequest) {
    return S3ConfigDto(
      dateYYYYmmDD: dateYYYYmmDD,
      xAmzDateHeader: xAmzDateHeader,
      xAmzDateExpires: xAmzDateExpires,
      bucket: bucket,
      payloadHash: payloadHash,
      defaultHeaders: defaultHeaders,
      canonicalRequest: newCanonicalRequest,
      signature: signature,
    );
  }

  S3ConfigDto setSignature(S3ConfigSignatureDto newSignature) {
    return S3ConfigDto(
      dateYYYYmmDD: dateYYYYmmDD,
      xAmzDateHeader: xAmzDateHeader,
      xAmzDateExpires: xAmzDateExpires,
      bucket: bucket,
      payloadHash: payloadHash,
      defaultHeaders: defaultHeaders,
      canonicalRequest: canonicalRequest,
      signature: newSignature,
    );
  }
}

final class S3ConfigSignatureDto {
  final String algorithm;
  final String credential;
  final String signedHeaders;
  final String signature;

  const S3ConfigSignatureDto({
    required this.algorithm,
    required this.credential,
    required this.signedHeaders,
    required this.signature,
  });

  const S3ConfigSignatureDto.empty()
      : algorithm = '',
        credential = '',
        signedHeaders = '',
        signature = '';
}
