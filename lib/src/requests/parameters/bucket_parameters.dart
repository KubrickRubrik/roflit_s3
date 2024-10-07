final class BucketListObjectParameters {
  /// Used to get the next part of the list if all the results do not fit into one response.
  /// To get the next part of the list, use the `NextContinuationToken value` from the previous answer.
  final String? continuationToken;

  /// The maximum number of elements in the response.
  /// This option should be used if you need to receive fewer than 1000 items in a single response.
  /// If more keys fall under the selection criteria than fit in the search results, then the
  /// answer contains `<IsTruncated>true</IsTruncated>`.
  final int? maxKeys;

  /// Separator character.
  /// If specified, Object Storage treats the key as a file path, with directories separated by a
  ///  delimiter character. In response to the request, the user will see a list of files and
  /// directories in the bucket. Files will be displayed in Contents elements,
  /// and directories in CommonPrefixes elements.

  /// If the prefix parameter is also specified in the request, then Object Storage will return
  /// a list of files and directories in the prefix directory.
  final String? delimiter;

  /// Object Storage will only select keys that start with prefix.
  final String? prefix;

  /// The key to start listing with.
  final String? startAfter;

  const BucketListObjectParameters({
    this.continuationToken,
    this.maxKeys,
    this.delimiter,
    this.prefix,
    this.startAfter,
  });

  const BucketListObjectParameters.empty()
      : continuationToken = '',
        maxKeys = 1000,
        delimiter = '',
        prefix = '',
        startAfter = '';

  String get _continuationUrl =>
      (continuationToken?.isNotEmpty == true) ? '&continuation-token=$continuationToken' : '';

  String get _maxKeysUrl => (maxKeys != null && maxKeys! > 0) ? '&max-keys=$maxKeys' : '';

  String get _delimiterUrl => (delimiter?.isNotEmpty == true) ? '&delimiter=$delimiter' : '';

  String get _prefixUrl => (prefix?.isNotEmpty == true) ? '&prefix=$prefix' : '';

  String get _startAfterUrl => (startAfter?.isNotEmpty == true) ? '&start-after=$startAfter' : '';

  String get queryString =>
      'list-type=2$_continuationUrl$_maxKeysUrl$_delimiterUrl$_prefixUrl$_startAfterUrl';
}
