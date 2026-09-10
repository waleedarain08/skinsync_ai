import 'package:intl/intl.dart';

List<Map<String, String>> getNextNDays(int n) {
  final now = DateTime.now();
  final List<Map<String, String>> dates = [];

  for (int i = 0; i < n; i++) {
    final date = now.add(Duration(days: i));
    final dayInitial = _getDayString(date.weekday);
    dates.add({
      "date": date.day.toString().padLeft(2, '0'),
      "day": dayInitial, // or dayInitial if you want short "Mon", "Tue"
    });
  }

  return dates;
}

String _getDayString(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return "Mon";
    case DateTime.tuesday:
      return "Tue";
    case DateTime.wednesday:
      return "Wed";
    case DateTime.thursday:
      return "Thu";
    case DateTime.friday:
      return "Fri";
    case DateTime.saturday:
      return "Sat";
    case DateTime.sunday:
      return "Sun";
    default:
      return "";
  }
}

class DateTimeUtils {
  static DateTime fromTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }
  

  static String formatTimestamp(int timestamp, {String pattern = 'dd MMM yyyy'}) {
    return DateFormat(pattern).format(fromTimestamp(timestamp));
  }

  static String formatTimestampToDayDate(int timestamp) {
    return DateFormat('EEEE, MMM d, yyyy').format(fromTimestamp(timestamp));
  }

  static String formatTimestampToTime(int timestamp) {
    return DateFormat('hh:mm a').format(fromTimestamp(timestamp));
  }

  static String formatISOStringToDateTime(String isoString, {String pattern = 'dd MMM yyyy hh:mm a'}) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat(pattern).format(dateTime);
    } catch (e) {
      return isoString;
    }
  }
}

extension DateTimeExtension on DateTime {
  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String get formattedTime {
    return DateFormat('hh:mm a').format(this);
  }

  String get formattedDateTime {
    return DateFormat('dd MMM yyyy hh:mm a').format(this);
  }

  String get formattedWeekdayDateTime {
    return DateFormat('EEE MMM dd - hh:mm a').format(this);
  }

  String get formattedDayDate {
    return DateFormat('EEEE, MMM d, yyyy').format(this);
  }

  String get formattedTime24 {
  return DateFormat('HH:mm').format(this);
}

  String get formattedFullDate {
    return DateFormat('MMMM dd, yyyy').format(this);
  }

    int get secondsSinceEpoch {
      return millisecondsSinceEpoch ~/ 1000;
    }
}
