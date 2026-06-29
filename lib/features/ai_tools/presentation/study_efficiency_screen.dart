import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';

class StudyEfficiencyScreen extends StatelessWidget {
  const StudyEfficiencyScreen({super.key});

  static final _data = [
    const FlSpot(6, 30), const FlSpot(7, 45), const FlSpot(8, 72), const FlSpot(9, 85), const FlSpot(10, 80),
    const FlSpot(11, 75), const FlSpot(12, 55), const FlSpot(13, 40), const FlSpot(14, 60), const FlSpot(15, 78),
    const FlSpot(16, 82), const FlSpot(17, 79), const FlSpot(18, 65), const FlSpot(19, 70), const FlSpot(20, 75),
    const FlSpot(21, 68), const FlSpot(22, 50), const FlSpot(23, 35),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('시간대별 학습 효율'), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('나의 집중력 황금 시간대', style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text('오늘 공부 데이터 기반', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSizes.spaceLg),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24, getTitlesWidget: (v, _) {
                        if (v % 3 != 0) return const SizedBox.shrink();
                        return Text('${v.toInt()}시', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10));
                      })),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _data,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    minX: 6, maxX: 23, minY: 0, maxY: 100,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: AppSizes.spaceLg),
          Text('시간대별 분석', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSizes.spaceMd),
          ...[
            const _EfficiencySlot(time: '오전 8~10시', efficiency: 85, emoji: '🌅', label: '최고 집중'),
            const _EfficiencySlot(time: '오후 3~5시', efficiency: 80, emoji: '⚡', label: '높은 집중'),
            const _EfficiencySlot(time: '저녁 7~9시', efficiency: 72, emoji: '🌙', label: '좋은 집중'),
            const _EfficiencySlot(time: '점심 12~2시', efficiency: 45, emoji: '😴', label: '집중 저하'),
          ].map((slot) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(AppSizes.spaceMd),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusMd), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
            child: Row(children: [
              Text(slot.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(slot.time, style: AppTextStyles.titleSmall),
                  Text('${slot.efficiency}%', style: AppTextStyles.titleSmall.copyWith(color: slot.efficiency > 70 ? AppColors.success : AppColors.warning)),
                ]),
                const SizedBox(height: 4),
                Text(slot.label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: slot.efficiency / 100, backgroundColor: AppColors.border, color: slot.efficiency > 70 ? AppColors.success : AppColors.warning, minHeight: 4, borderRadius: BorderRadius.circular(2)),
              ])),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _EfficiencySlot {
  const _EfficiencySlot({required this.time, required this.efficiency, required this.emoji, required this.label});
  final String time;
  final int efficiency;
  final String emoji;
  final String label;
}
