import 'package:intl/intl.dart';

/// Date/time utility functions for StudyVerse.
abstract final class StudyDateUtils {
  // ── Formatters (lazily initialised) ───────────────────────────────────────

  static final DateFormat _dateFormatter = DateFormat('yyyy.MM.dd', 'ko');
  static final DateFormat _dateTimeFormatter =
      DateFormat('yyyy.MM.dd HH:mm', 'ko');
  static final DateFormat _timeFormatter = DateFormat('HH:mm', 'ko');
  static final DateFormat _monthFormatter = DateFormat('yyyy년 M월', 'ko');
  static final DateFormat _shortDateFormatter =
      DateFormat('M월 d일 (E)', 'ko');
  static final DateFormat _iso8601Formatter =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");

  // ── Formatting ────────────────────────────────────────────────────────────

  static String formatDate(DateTime date) => _dateFormatter.format(date);

  static String formatDateTime(DateTime date) =>
      _dateTimeFormatter.format(date);

  static String formatTime(DateTime date) => _timeFormatter.format(date);

  static String formatMonth(DateTime date) => _monthFormatter.format(date);

  static String formatShortDate(DateTime date) =>
      _shortDateFormatter.format(date);

  static String formatIso8601(DateTime date) =>
      _iso8601Formatter.format(date.toUtc());

  static String formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    final s = duration.inSeconds % 60;
    if (h > 0) {
      return '${h}시간 ${m.toString().padLeft(2, '0')}분 ${s.toString().padLeft(2, '0')}초';
    }
    if (m > 0) {
      return '${m}분 ${s.toString().padLeft(2, '0')}초';
    }
    return '${s}초';
  }

  static String formatTimerDisplay(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays == 1) return '어제';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}개월 전';
    return '${(diff.inDays / 365).floor()}년 전';
  }

  // ── Parsing ───────────────────────────────────────────────────────────────

  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    return DateTime.tryParse(dateString);
  }

  // ── Range helpers ─────────────────────────────────────────────────────────

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  static DateTime startOfWeek(DateTime date) {
    final offset = date.weekday - 1; // Monday = 1
    return startOfDay(date.subtract(Duration(days: offset)));
  }

  static DateTime endOfWeek(DateTime date) {
    final offset = 7 - date.weekday; // Days to next Sunday
    return endOfDay(date.add(Duration(days: offset)));
  }

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1).subtract(const Duration(days: 1));

  static DateRange thisWeek() {
    final now = DateTime.now();
    return DateRange(start: startOfWeek(now), end: endOfWeek(now));
  }

  static DateRange thisMonth() {
    final now = DateTime.now();
    return DateRange(start: startOfMonth(now), end: endOfMonth(now));
  }

  static DateRange lastNDays(int n) {
    final now = DateTime.now();
    return DateRange(
      start: startOfDay(now.subtract(Duration(days: n - 1))),
      end: endOfDay(now),
    );
  }

  // ── Predicates ────────────────────────────────────────────────────────────

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  // ── Study helpers ─────────────────────────────────────────────────────────

  /// Returns streak count from a sorted list of study dates (most recent first).
  static int calculateStreak(List<DateTime> studyDates) {
    if (studyDates.isEmpty) return 0;

    final sorted = studyDates.map(startOfDay).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime cursor = startOfDay(DateTime.now());

    for (final date in sorted) {
      if (isSameDay(date, cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (date.isBefore(cursor)) {
        break;
      }
    }

    return streak;
  }

  /// Groups study sessions by date for the calendar view.
  static Map<DateTime, List<T>> groupByDay<T>(
    List<T> items,
    DateTime Function(T) dateExtractor,
  ) {
    final map = <DateTime, List<T>>{};
    for (final item in items) {
      final day = startOfDay(dateExtractor(item));
      map.putIfAbsent(day, () => []).add(item);
    }
    return map;
  }
}

/// Simple immutable date range.
final class DateRange {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);

  bool contains(DateTime date) =>
      !date.isBefore(start) && !date.isAfter(end);

  @override
  String toString() =>
      'DateRange(${StudyDateUtils.formatDate(start)} ~ ${StudyDateUtils.formatDate(end)})';
}
