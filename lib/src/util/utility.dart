import './extension.dart';

abstract final class Utility {
  static String get dateYYYYmmDD => DateTime.now().toUtc().yyyyMMdd; // YYYYMMDD
  static String get xAmzDateHeader => DateTime.now().toUtc().xAmzDate; // 20240301T120357Z
}
