import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/features/home/presentation/providers/home_provider.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------
// New accounts start at zero — real study sessions will populate these.
const _hourlyData = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
const _weekDays = ['월', '화', '수', '목', '금', '토', '일'];
const _weekHours = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

final _heatmapColors = [
  const Color(0xFFEBF3FF),
  const Color(0xFFB3D4FF),
  const Color(0xFF6AADFF),
  const Color(0xFF2B7FE0),
  const Color(0xFF1A5FB4),
];

int _heatIntensity(int day) => 0;

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 1; // default Week

  final _tabs = ['일', '주', '월', '년'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shareStats() {
    final data = ref.read(homeDataProvider);
    final hours = data?.todayStudyHours ?? 0;
    final streak = data?.streakDays ?? 0;
    final points = data?.points ?? 0;
    final text = '📚 StudyVerse 학습 통계\n'
        '오늘 순공: ${hours.toStringAsFixed(1)}시간\n'
        '연속 학습: $streak일\n'
        '포인트: $points P\n'
        '#StudyVerse #공부인증';
    Share.share(text, subject: 'StudyVerse 학습 통계');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('학습 통계', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: _shareStats,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabSelector(),
            const SizedBox(height: 16),
            _buildDateDisplay(),
            const SizedBox(height: 16),
            _buildTodaySummaryCard(),
            const SizedBox(height: 16),
            _buildBarChartCard(),
            const SizedBox(height: 16),
            _buildMetricsRow(),
            const SizedBox(height: 16),
            _buildWeeklyGrid(),
            const SizedBox(height: 16),
            _buildHeatmapCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Tab selector ────────────────────────────────────────────────────────
  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = i);
                _tabController.animateTo(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _tabs[i],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ── Date display ────────────────────────────────────────────────────────
  Widget _buildDateDisplay() {
    final now = DateTime.now();
    final dateStr = '${now.year}년 ${now.month}월 ${now.day}일';
    return Row(
      children: [
        Text(dateStr,
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  // ── Today summary ───────────────────────────────────────────────────────
  Widget _buildTodaySummaryCard() {
    final data = ref.watch(homeDataProvider);
    final todayHours = data?.todayStudyHours ?? 0.0;
    final target = data?.targetHours ?? 8.0;
    final h = todayHours.floor();
    final m = ((todayHours - h) * 60).round();
    final progress = target > 0 ? (todayHours / target).clamp(0.0, 1.0) : 0.0;
    final remain = (target - todayHours).clamp(0.0, target);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1557B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('오늘 순공 시간',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('목표 ${target.toStringAsFixed(0)}시간',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$h시간 $m분',
              style: AppTextStyles.displaySmall.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text('목표까지 ${remain.toStringAsFixed(1)}시간 남았어요',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
        ],
      ),
    ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 150.ms).fadeIn();
  }

  // ── Bar chart ───────────────────────────────────────────────────────────
  Widget _buildBarChartCard() {
    return Container(
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
              Text('시간대별 공부 시간',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
              Text('단위: 시간',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 3.0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final labels = ['8시', '9시', '10시', '11시', '12시', '13시', '14시', '15시', '16시', '17시', '18시', '19시'];
                        final i = v.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            i < labels.length ? labels[i] : '',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.textSecondary, fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.surfaceVariant,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_hourlyData.length, (i) {
                  final val = _hourlyData[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val,
                        color: val >= 2.0 ? AppColors.primary : AppColors.primaryLight,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  // ── Metrics row ─────────────────────────────────────────────────────────
  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.bolt_rounded,
            iconColor: AppColors.warning,
            label: '집중도',
            value: '0%',
            sub: '오늘 평균',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.replay_rounded,
            iconColor: AppColors.success,
            label: '공부 세션',
            value: '0회',
            sub: '오늘 세션 수',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.accent,
            label: '연속 학습',
            value: '0일',
            sub: '현재 스트릭',
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ── Weekly grid ─────────────────────────────────────────────────────────
  Widget _buildWeeklyGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이번 주 공부 시간',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_weekDays.length, (i) {
              final hours = _weekHours[i];
              final maxH = 6.0;
              final ratio = hours / maxH;
              final isToday = i == 4;
              return Column(
                children: [
                  Text('${hours.toStringAsFixed(0)}h',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: isToday ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 32,
                      height: 80 * ratio,
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primary : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_weekDays[i],
                      style: AppTextStyles.labelSmall.copyWith(
                          color: isToday ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('이번 주 총 공부 시간',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text('0시간',
                  style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
  }

  // ── Heatmap card ─────────────────────────────────────────────────────────
  Widget _buildHeatmapCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('5월 학습 히트맵',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _buildCalendarHeatmap(),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('적음', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Row(
                children: _heatmapColors.map((c) {
                  return Container(
                    width: 16, height: 16,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
                  );
                }).toList(),
              ),
              const SizedBox(width: 4),
              Text('많음', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildCalendarHeatmap() {
    const cellSize = 36.0;
    const cols = 7;
    final rows = (31 / cols).ceil() + 1;
    final startOffset = 2; // May starts Wednesday

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: cols * rows,
      itemBuilder: (_, idx) {
        final day = idx - startOffset + 1;
        if (day < 1 || day > 31) {
          return const SizedBox();
        }
        final intensity = _heatIntensity(day);
        final color = _heatmapColors[intensity];
        final isToday = day == 20;
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: isToday
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: intensity >= 3 ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}
