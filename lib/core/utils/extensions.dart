import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ── BuildContext extensions ───────────────────────────────────────────────────

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get topPadding => MediaQuery.of(this).padding.top;
  double get bottomPadding => MediaQuery.of(this).padding.bottom;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  NavigatorState get navigator => Navigator.of(this);

  void showSnackBar(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

// ── DateTime extensions ───────────────────────────────────────────────────────

extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 60) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}달 전';
    return '${(diff.inDays / 365).floor()}년 전';
  }

  String get formattedDate => DateFormat('yyyy.MM.dd', 'ko').format(this);

  String get formattedDateTime =>
      DateFormat('yyyy.MM.dd HH:mm', 'ko').format(this);

  String get formattedTime => DateFormat('HH:mm', 'ko').format(this);

  String get formattedMonth => DateFormat('yyyy년 M월', 'ko').format(this);

  String get weekdayShort {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay =>
      DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfWeek =>
      subtract(Duration(days: weekday - 1)).startOfDay;

  DateTime get startOfMonth => DateTime(year, month);

  DateTime get endOfMonth => DateTime(year, month + 1).subtract(
        const Duration(milliseconds: 1),
      );
}

// ── Duration extensions ───────────────────────────────────────────────────────

extension DurationX on Duration {
  /// Formats as HH:MM:SS
  String get formatted {
    final h = inHours.toString().padLeft(2, '0');
    final m = (inMinutes % 60).toString().padLeft(2, '0');
    final s = (inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Formats as MM:SS (for short durations)
  String get formattedShort {
    final m = inMinutes.toString().padLeft(2, '0');
    final s = (inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Human-readable, e.g. "2시간 30분"
  String get humanReadable {
    if (inHours > 0) {
      final remaining = inMinutes % 60;
      if (remaining == 0) return '${inHours}시간';
      return '${inHours}시간 ${remaining}분';
    }
    if (inMinutes > 0) return '${inMinutes}분';
    return '${inSeconds}초';
  }
}

// ── int extensions ────────────────────────────────────────────────────────────

extension IntX on int {
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);

  String get withComma {
    final formatter = NumberFormat('#,###', 'ko');
    return formatter.format(this);
  }

  /// Formats study points with 'P' suffix: 1,250P
  String get asPoints => '${withComma}P';
}

// ── double extensions ─────────────────────────────────────────────────────────

extension DoubleX on double {
  String get withComma {
    final formatter = NumberFormat('#,##0.##', 'ko');
    return formatter.format(this);
  }

  /// Converts a fraction [0.0–1.0] to percentage string: "75%"
  String get asPercent => '${(this * 100).toStringAsFixed(0)}%';
}

// ── String extensions ─────────────────────────────────────────────────────────

extension StringX on String {
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9.!#$%&'
      r"'*+/=?^_`{|}~-]+"
      r'@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
      r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    ).hasMatch(this);
  }

  bool get isValidPassword => length >= 8;

  bool get isValidNickname =>
      length >= 2 && length <= 20 && RegExp(r'^[가-힣a-zA-Z0-9_]+$').hasMatch(this);

  String get initials {
    final parts = trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return length >= 2 ? substring(0, 2).toUpperCase() : toUpperCase();
  }

  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
}

// ── List extensions ───────────────────────────────────────────────────────────

extension ListX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  List<T> separatedBy(T separator) {
    if (isEmpty) return this;
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }
}
