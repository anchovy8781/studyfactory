import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:table_calendar/table_calendar.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------
Map<DateTime, double> _buildStudyData() {
  final now = DateTime.now();
  return {
    DateTime(now.year, now.month, 1): 2.5,
    DateTime(now.year, now.month, 2): 4.0,
    DateTime(now.year, now.month, 3): 0.0,
    DateTime(now.year, now.month, 4): 5.5,
    DateTime(now.year, now.month, 5): 3.0,
    DateTime(now.year, now.month, 6): 6.0,
    DateTime(now.year, now.month, 7): 5.0,
    DateTime(now.year, now.month, 8): 2.0,
    DateTime(now.year, now.month, 9): 4.5,
    DateTime(now.year, now.month, 10): 5.5,
    DateTime(now.year, now.month, 11): 3.5,
    DateTime(now.year, now.month, 12): 0.0,
    DateTime(now.year, now.month, 13): 0.0,
    DateTime(now.year, now.month, 14): 7.0,
    DateTime(now.year, now.month, 15): 5.5,
    DateTime(now.year, now.month, 16): 4.0,
    DateTime(now.year, now.month, 17): 6.5,
    DateTime(now.year, now.month, 18): 5.0,
    DateTime(now.year, now.month, 19): 3.5,
    DateTime(now.year, now.month, 20): 5.5,
  };
}

final _studyData = _buildStudyData();

final _sessionsByDay = {
  20: [
    _StudySession(subject: '전기기사', duration: '2시간 30분', startTime: '09:00', endTime: '11:30'),
    _StudySession(subject: '회로이론', duration: '1시간 45분', startTime: '14:00', endTime: '15:45'),
    _StudySession(subject: '전기기기', duration: '1시간 15분', startTime: '20:00', endTime: '21:15'),
  ],
  19: [
    _StudySession(subject: '전기기사', duration: '2시간', startTime: '10:00', endTime: '12:00'),
    _StudySession(subject: '전력공학', duration: '1시간 30분', startTime: '19:00', endTime: '20:30'),
  ],
  18: [
    _StudySession(subject: '전기기사', duration: '3시간', startTime: '09:00', endTime: '12:00'),
    _StudySession(subject: '전기자기학', duration: '2시간', startTime: '15:00', endTime: '17:00'),
  ],
};

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  double _getStudyHours(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _studyData[key] ?? 0.0;
  }

  Color _dayColor(double hours) {
    if (hours == 0) return Colors.transparent;
    if (hours < 2) return AppColors.primaryLight.withOpacity(0.4);
    if (hours < 4) return AppColors.primaryLight;
    if (hours < 6) return AppColors.primary.withOpacity(0.7);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('학습 캘린더', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthlySummary(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCalendar(),
                  const SizedBox(height: 12),
                  _buildHeatmapLegend(),
                  const SizedBox(height: 16),
                  _buildDayDetail(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Monthly summary ──────────────────────────────────────────────────────
  Widget _buildMonthlySummary() {
    final totalHours = _studyData.values.fold(0.0, (a, b) => a + b);
    final studyDays = _studyData.values.where((h) => h > 0).length;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              label: '이번 달 총 공부',
              value: '${totalHours.toStringAsFixed(0)}시간',
              icon: Icons.timer_outlined,
              color: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
            child: _buildSummaryItem(
              label: '공부한 날',
              value: '$studyDays일',
              icon: Icons.calendar_today_rounded,
              color: AppColors.success,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
            child: _buildSummaryItem(
              label: '연속 학습',
              value: '21일',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
      ],
    );
  }

  // ── Calendar ─────────────────────────────────────────────────────────────
  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        onPageChanged: (focused) => setState(() => _focusedDay = focused),
        locale: 'ko_KR',
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          titleTextStyle: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle:
              AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
          rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          weekendStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w700),
          defaultTextStyle: AppTextStyles.bodySmall,
          weekendTextStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          selectedTextStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final hours = _getStudyHours(day);
            if (hours == 0) return null;
            final bgColor = _dayColor(hours);
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: hours >= 4 ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  // ── Heatmap legend ───────────────────────────────────────────────────────
  Widget _buildHeatmapLegend() {
    final items = [
      ('0시간', Colors.transparent),
      ('1-2시간', AppColors.primaryLight.withOpacity(0.4)),
      ('2-4시간', AppColors.primaryLight),
      ('4-6시간', AppColors.primary.withOpacity(0.7)),
      ('6시간+', AppColors.primary),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.$2,
                    shape: BoxShape.circle,
                    border: item.$2 == Colors.transparent
                        ? Border.all(color: AppColors.divider)
                        : null,
                  ),
                ),
                const SizedBox(width: 3),
                Text(item.$1,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Day detail ───────────────────────────────────────────────────────────
  Widget _buildDayDetail() {
    if (_selectedDay == null) return const SizedBox();

    final day = _selectedDay!;
    final hours = _getStudyHours(day);
    final sessions = _sessionsByDay[day.day] ?? [];
    final dateStr =
        '${day.year}년 ${day.month}월 ${day.day}일';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr,
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
              if (hours > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('총 ${hours}시간',
                      style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (sessions.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.event_note_rounded,
                      color: AppColors.textSecondary, size: 40),
                  const SizedBox(height: 8),
                  Text('이 날은 공부 기록이 없어요',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            )
          else
            ...List.generate(sessions.length, (i) {
              final session = sessions[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.subject,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700)),
                          Text('${session.startTime} - ${session.endTime}',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(session.duration,
                          style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms, delay: (i * 60).ms),
              );
            }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------
class _StudySession {
  final String subject;
  final String duration;
  final String startTime;
  final String endTime;

  const _StudySession({
    required this.subject,
    required this.duration,
    required this.startTime,
    required this.endTime,
  });
}
