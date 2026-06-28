import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------
const _statCards = [
  _StatCard(
    icon: Icons.people_rounded,
    color: Color(0xFF1A73E8),
    label: '실시간 사용자',
    value: '1,248명',
    change: '+12%',
    isPositive: true,
  ),
  _StatCard(
    icon: Icons.timer_rounded,
    color: Color(0xFF4CAF50),
    label: '오늘 순공 시간',
    value: '12,430시간',
    change: '+8%',
    isPositive: true,
  ),
  _StatCard(
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFFF6B35),
    label: 'AI 위험 사용자',
    value: '23명',
    change: '-5%',
    isPositive: true,
  ),
  _StatCard(
    icon: Icons.report_outlined,
    color: Color(0xFFE53935),
    label: '신고 건수',
    value: '15건',
    change: '+3%',
    isPositive: false,
  ),
];

final _lineData = [
  const FlSpot(0, 3.2),
  const FlSpot(1, 5.1),
  const FlSpot(2, 4.8),
  const FlSpot(3, 6.2),
  const FlSpot(4, 5.9),
  const FlSpot(5, 7.4),
  const FlSpot(6, 8.1),
];

final _pieData = [
  _PieSlice(label: '자격증 준비', value: 51, color: Color(0xFF1A73E8)),
  _PieSlice(label: '코딩공부', value: 20, color: Color(0xFF4CAF50)),
  _PieSlice(label: '서버 이탈 감지', value: 15, color: Color(0xFFFF6B35)),
  _PieSlice(label: '기타', value: 14, color: Color(0xFFE0E0E0)),
];

const _navItems = [
  _NavItem(icon: Icons.dashboard_rounded, label: '대시보드'),
  _NavItem(icon: Icons.manage_accounts_rounded, label: '사용자 관리'),
  _NavItem(icon: Icons.verified_user_outlined, label: 'AI 인증 모니터링'),
  _NavItem(icon: Icons.flag_outlined, label: '신고 관리'),
  _NavItem(icon: Icons.card_giftcard_rounded, label: '리워드 관리'),
  _NavItem(icon: Icons.analytics_outlined, label: '통계'),
  _NavItem(icon: Icons.settings_rounded, label: '시스템 설정'),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  _buildSidebar(),
                  Expanded(child: _buildMainContent()),
                ],
              )
            : Column(
                children: [
                  _buildMobileTopBar(),
                  Expanded(child: _buildMainContent()),
                  _buildMobileBottomNav(),
                ],
              ),
      ),
    );
  }

  // ── Sidebar (desktop/tablet) ─────────────────────────────────────────────
  Widget _buildSidebar() {
    return Container(
      width: 220,
      color: AppColors.primary,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('🎓', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text('관리자',
                    style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final selected = i == _selectedNav;
            return GestureDetector(
              onTap: () => setState(() => _selectedNav = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(item.icon,
                        color: selected ? Colors.white : Colors.white60, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: selected ? Colors.white : Colors.white70,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          )),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('👤', style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('관리자',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                      Text('admin@studyverse.kr',
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.white60),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile top bar ───────────────────────────────────────────────────────
  Widget _buildMobileTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.primary,
      child: Row(
        children: [
          const Text('🎓', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text('StudyVerse 관리자',
              style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          const Spacer(),
          const Icon(Icons.notifications_outlined, color: Colors.white),
        ],
      ),
    );
  }

  // ── Mobile bottom nav ────────────────────────────────────────────────────
  Widget _buildMobileBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Row(
        children: List.generate(
          _navItems.length > 5 ? 5 : _navItems.length,
          (i) {
            final item = _navItems[i];
            final selected = i == _selectedNav;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedNav = i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon,
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                          size: 22),
                      const SizedBox(height: 3),
                      Text(item.label.split(' ').first,
                          style: TextStyle(
                              fontSize: 10,
                              color: selected ? AppColors.primary : AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Main content ─────────────────────────────────────────────────────────
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentHeader(),
          const SizedBox(height: 16),
          _buildStatCards(),
          const SizedBox(height: 16),
          _buildChartRow(),
          const SizedBox(height: 16),
          _buildRecentActivityTable(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('대시보드',
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
            Text('2024년 5월 20일 · 실시간 현황',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('시스템 정상',
                  style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.success, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Stat cards row ───────────────────────────────────────────────────────
  Widget _buildStatCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            children: List.generate(_statCards.length, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < _statCards.length - 1 ? 12 : 0),
                  child: _buildStatCardWidget(_statCards[i], i),
                ),
              );
            }),
          );
        }
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: List.generate(_statCards.length, (i) {
            return _buildStatCardWidget(_statCards[i], i);
          }),
        );
      },
    );
  }

  Widget _buildStatCardWidget(_StatCard card, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(card.icon, color: card.color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: card.isPositive ? AppColors.successLight : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(card.change,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: card.isPositive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(card.value,
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(card.label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).slideY(begin: 0.1);
  }

  // ── Charts row ───────────────────────────────────────────────────────────
  Widget _buildChartRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildLineChart()),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildPieChart()),
            ],
          );
        }
        return Column(
          children: [
            _buildLineChart(),
            const SizedBox(height: 12),
            _buildPieChart(),
          ],
        );
      },
    );
  }

  Widget _buildLineChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('순공 시간 추이',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
          Text('최근 7일',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 2,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}k',
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ['월', '화', '수', '목', '금', '토', '일'];
                        final i = v.toInt();
                        return Text(
                          i < days.length ? days[i] : '',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: _lineData,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildPieChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('사용자 분포',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
          Text('학습 목적별',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _pieData.map((p) {
                  return PieChartSectionData(
                    color: p.color,
                    value: p.value.toDouble(),
                    title: '${p.value}%',
                    radius: 45,
                    titleStyle: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: _pieData.map((p) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(p.label,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary)),
                    ),
                    Text('${p.value}%',
                        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }

  // ── Recent activity table ─────────────────────────────────────────────────
  Widget _buildRecentActivityTable() {
    final activities = [
      ['user_2048', '신고 접수', '부적절한 게시글', '2분 전', '검토 중'],
      ['user_1203', 'AI 인증 실패', '10회 연속 실패', '15분 전', '경고'],
      ['user_3301', '포인트 교환', '스타벅스 4,100P', '32분 전', '완료'],
      ['user_0812', '계정 정지 요청', '반복 신고 대상', '1시간 전', '대기'],
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('최근 활동',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () {},
                child: Text('전체 보기',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 52,
              headingTextStyle: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w700),
              dataTextStyle: AppTextStyles.bodySmall,
              dividerThickness: 0.5,
              columns: const [
                DataColumn(label: Text('사용자')),
                DataColumn(label: Text('이벤트')),
                DataColumn(label: Text('상세')),
                DataColumn(label: Text('시간')),
                DataColumn(label: Text('상태')),
              ],
              rows: activities.map((row) {
                return DataRow(cells: [
                  DataCell(Text(row[0],
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary))),
                  DataCell(Text(row[1])),
                  DataCell(Text(row[2])),
                  DataCell(Text(row[3],
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))),
                  DataCell(_buildStatusChip(row[4])),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case '완료':
        color = AppColors.success;
        break;
      case '경고':
        color = AppColors.warning;
        break;
      case '대기':
        color = AppColors.textSecondary;
        break;
      default:
        color = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status,
          style: AppTextStyles.labelSmall.copyWith(
              color: color, fontWeight: FontWeight.w700)),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------
class _StatCard {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String change;
  final bool isPositive;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
  });
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

class _PieSlice {
  final String label;
  final int value;
  final Color color;

  const _PieSlice({required this.label, required this.value, required this.color});
}
