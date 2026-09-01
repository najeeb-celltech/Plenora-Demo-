class AppDateTimeUtils {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  static const List<String> _fullMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  static const List<String> _fullWeekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  /// Short month name (1-indexed: 1 = Jan, 12 = Dec)
  static String getMonthShort(int month) {
    if (month < 1 || month > 12) return 'Jan';
    return _months[month - 1];
  }

  /// Full month name (1-indexed: 1 = January, 12 = December)
  static String getMonthFull(int month) {
    if (month < 1 || month > 12) return 'January';
    return _fullMonths[month - 1];
  }

  /// Short weekday name (1-indexed: 1 = Mon, 7 = Sun)
  static String getWeekdayShort(int weekday) {
    if (weekday < 1 || weekday > 7) return 'Mon';
    return _weekdays[weekday - 1];
  }

  /// Full weekday name (1-indexed: 1 = Monday, 7 = Sunday)
  static String getWeekdayFull(int weekday) {
    if (weekday < 1 || weekday > 7) return 'Monday';
    return _fullWeekdays[weekday - 1];
  }

  /// Returns dynamically generated upcoming selectable dates based on device's current date/time.
  /// Example: ["Today, Sep 1", "Tomorrow, Sep 2", "Thu, Sep 3", "Fri, Sep 4", "Sat, Sep 5"]
  static List<String> getAvailableDates({int count = 5}) {
    final now = DateTime.now();
    final List<String> dates = [];

    for (int i = 0; i < count; i++) {
      final date = now.add(Duration(days: i));
      final monthStr = getMonthShort(date.month);
      final day = date.day;

      if (i == 0) {
        dates.add("Today, $monthStr $day");
      } else if (i == 1) {
        dates.add("Tomorrow, $monthStr $day");
      } else {
        final weekdayStr = getWeekdayShort(date.weekday);
        dates.add("$weekdayStr, $monthStr $day");
      }
    }
    return dates;
  }

  /// Returns available appointment time slots throughout the day.
  static List<String> getAvailableTimes() {
    return const [
      "09:00 AM",
      "11:30 AM",
      "02:00 PM",
      "04:30 PM",
      "06:30 PM",
    ];
  }

  /// Default date string for checkout or scheduling (e.g. "Today, Sep 1")
  static String getDefaultBookingDate() {
    return getAvailableDates().first;
  }

  /// Default time string for checkout or scheduling (e.g. "09:00 AM")
  static String getDefaultBookingTime() {
    return getAvailableTimes().first;
  }

  /// Formats a DateTime into a friendly date string (e.g., "Sep 1, 2026")
  static String formatDate(DateTime dt) {
    final local = dt.toLocal();
    return "${getMonthShort(local.month)} ${local.day}, ${local.year}";
  }

  /// Formats a DateTime into a 12-hour time string with AM/PM (e.g., "10:30 AM")
  static String formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    final hourStr = formattedHour.toString().padLeft(2, '0');
    return "$hourStr:$minute $period";
  }

  /// Formats relative time from now (e.g., "Just now", "10m ago", "1h ago", "1d ago")
  static String formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inSeconds < 60 && difference.inSeconds >= 0) {
      return "Just now";
    } else if (difference.inMinutes < 60 && difference.inMinutes >= 0) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24 && difference.inHours >= 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7 && difference.inDays >= 0) {
      return "${difference.inDays}d ago";
    } else {
      return formatDate(dt);
    }
  }

  /// Formatted date string for tomorrow
  static String getTomorrowScheduleFormatted() {
    return "tomorrow at 10:00 AM";
  }

  /// Current year string (e.g., "2026")
  static String getCurrentYearString() {
    return DateTime.now().year.toString();
  }
}
