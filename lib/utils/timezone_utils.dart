import 'package:flutter_timezone/flutter_timezone.dart';

class TimezoneUtils {
  /// Returns e.g. { "timezone": "Asia/Karachi", "utc_offset": "+05:00" }
  static Future<Map<String, String>> getTimezoneInfo() async {
    String timezoneName;
    try {
      timezoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (e) {
      timezoneName = "UTC";
    }

    final offset = DateTime.now().timeZoneOffset;

    return {"timezone": timezoneName, "utc_offset": _formatOffset(offset)};
  }

  static String _formatOffset(Duration offset) {
    final sign = offset.isNegative ? "-" : "+";
    final abs = offset.abs();
    final hours = abs.inHours.toString().padLeft(2, '0');
    final minutes = (abs.inMinutes % 60).toString().padLeft(2, '0');
    return "$sign$hours:$minutes";
  }
}
