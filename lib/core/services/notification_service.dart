import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// A stored in-app notification.
class AppNotification {
  AppNotification({
    required this.title,
    required this.body,
    required this.timestamp,
    this.read = false,
  });

  final String title;
  final String body;
  final int timestamp;
  bool read;

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'timestamp': timestamp,
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        timestamp: (j['timestamp'] as num?)?.toInt() ?? 0,
        read: j['read'] as bool? ?? false,
      );

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(timestamp);
}

/// Local notifications (system tray) + an in-app notification inbox stored on
/// device. Real remote push would additionally require a server to send via
/// FCM; this delivers genuine on-device notifications without a backend.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _storeKey = 'sv_notifications';
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    try {
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
      } catch (_) {/* default UTC */}
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _inited = true;
    } catch (e) {
      debugPrint('[Notif] init failed: $e');
    }
  }

  static const _reminderId = 7001;

  /// Schedule (or reschedule) a daily study reminder at [hour]:[minute].
  Future<void> scheduleDailyReminder(int hour, int minute) async {
    await init();
    try {
      await _plugin.cancel(_reminderId);
      final now = tz.TZDateTime.now(tz.local);
      var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (when.isBefore(now)) when = when.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        _reminderId,
        '공부할 시간이에요! 📚',
        '오늘의 학습 목표를 향해 출발해볼까요?',
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'studyverse_reminder',
            '공부 리마인더',
            channelDescription: '설정한 시간의 학습 알림',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // daily
      );
    } catch (e) {
      debugPrint('[Notif] schedule failed: $e');
    }
  }

  Future<void> cancelDailyReminder() async {
    try {
      await _plugin.cancel(_reminderId);
    } catch (_) {/* ignore */}
  }

  /// Show a system notification AND save it to the in-app inbox.
  Future<void> notify(String title, String body) async {
    await _saveToInbox(title, body);
    try {
      await init();
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'studyverse_default',
          'StudyVerse 알림',
          channelDescription: '학습 리마인더 및 리워드 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
      );
    } catch (e) {
      debugPrint('[Notif] show failed: $e');
    }
  }

  Future<void> _saveToInbox(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getInbox();
    list.insert(
      0,
      AppNotification(
        title: title,
        body: body,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    final trimmed = list.take(50).toList();
    await prefs.setString(
      _storeKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<AppNotification>> getInbox() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) =>
              AppNotification.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> unreadCount() async =>
      (await getInbox()).where((n) => !n.read).length;

  Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getInbox();
    for (final n in list) {
      n.read = true;
    }
    await prefs.setString(
      _storeKey,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storeKey);
  }
}
