extension EDateTime on DateTime {
  /// Format YYYYMMDD
  String get yyyyMMdd {
    return '$year${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}';
  }

  /// Format 20240301T120357Z
  String get xAmzDate {
    return '$year${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}T${hour.toString().padLeft(2, '0')}${minute.toString().padLeft(2, '0')}'
        '${second.toString().padLeft(2, '0')}Z';
  }
}
