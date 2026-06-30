import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// Subject grade-improvement tracker.
///
/// Users log exam scores per subject over time; the screen draws a line chart
/// per subject so they can see their improvement (성적 향상도) at a glance.
class GradeGraphScreen extends StatefulWidget {
  const GradeGraphScreen({super.key});

  @override
  State<GradeGraphScreen> createState() => _GradeGraphScreenState();
}

class _GradeGraphScreenState extends State<GradeGraphScreen> {
  static const _subjectColors = [
    AppColors.primary,
    Color(0xFFEF6C00),
    Color(0xFF2E7D32),
    Color(0xFF8E24AA),
    Color(0xFFC62828),
    Color(0xFF00838F),
  ];

  CollectionReference<Map<String, dynamic>>? get _grades {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('grades');
  }

  @override
  Widget build(BuildContext context) {
    final grades = _grades;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text('과목 성적 향상도', style: AppTextStyles.titleLarge),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: grades == null ? null : () => _showAddDialog(grades),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('성적 입력', style: TextStyle(color: Colors.white)),
      ),
      body: grades == null
          ? _empty('로그인이 필요합니다.')
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: grades.orderBy('date', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _empty('성적을 불러올 수 없습니다.\nFirestore 규칙을 확인하세요.');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return _empty('아직 입력한 성적이 없어요.\n시험 점수를 기록하고 향상도를 확인해보세요!');
                }
                return _buildContent(docs);
              },
            ),
    );
  }

  Widget _buildContent(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    // Group records by subject.
    final bySubject = <String, List<_Record>>{};
    for (final d in docs) {
      final m = d.data();
      final subject = (m['subject'] as String?)?.trim() ?? '기타';
      final score = (m['score'] as num?)?.toDouble() ?? 0;
      final date = (m['date'] as Timestamp?)?.toDate() ?? DateTime.now();
      final exam = (m['examName'] as String?)?.trim() ?? '';
      bySubject
          .putIfAbsent(subject, () => [])
          .add(_Record(d.reference, score, date, exam, subject));
    }
    final subjects = bySubject.keys.toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        _buildChartCard(bySubject, subjects),
        const SizedBox(height: 16),
        ...subjects.asMap().entries.map((e) {
          final color = _subjectColors[e.key % _subjectColors.length];
          return _buildSubjectCard(e.value, bySubject[e.value]!, color);
        }),
      ],
    );
  }

  Widget _buildChartCard(
      Map<String, List<_Record>> bySubject, List<String> subjects) {
    final allScores =
        bySubject.values.expand((l) => l).map((r) => r.score).toList();
    final maxScore = allScores.isEmpty
        ? 100.0
        : allScores.reduce((a, b) => a > b ? a : b).clamp(10.0, 1000.0);
    final maxY = (maxScore <= 100) ? 100.0 : ((maxScore / 10).ceil() * 10).toDouble();

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
          Text('성적 추이',
              style:
                  AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: subjects.asMap().entries.map((e) {
              final color = _subjectColors[e.key % _subjectColors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, color: color),
                  const SizedBox(width: 4),
                  Text(e.value,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppColors.surfaceVariant, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: maxY / 5,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData:
                    subjects.asMap().entries.map((entry) {
                  final records = bySubject[entry.value]!;
                  final color =
                      _subjectColors[entry.key % _subjectColors.length];
                  return LineChartBarData(
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    spots: records
                        .asMap()
                        .entries
                        .map((r) =>
                            FlSpot(r.key.toDouble(), r.value.score))
                        .toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(
      String subject, List<_Record> records, Color color) {
    final first = records.first.score;
    final last = records.last.score;
    final diff = last - first;
    final improving = diff >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            children: [
              Container(width: 10, height: 10, color: color),
              const SizedBox(width: 8),
              Text(subject,
                  style: AppTextStyles.titleSmall
                      .copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (records.length > 1)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (improving ? AppColors.success : AppColors.error)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          improving
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 14,
                          color: improving
                              ? AppColors.success
                              : AppColors.error),
                      const SizedBox(width: 4),
                      Text(
                          '${improving ? '+' : ''}${diff.toStringAsFixed(diff.truncateToDouble() == diff ? 0 : 1)}',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: improving
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...records.reversed.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.exam.isEmpty
                            ? '${r.date.year}.${r.date.month}.${r.date.day}'
                            : '${r.exam} · ${r.date.year}.${r.date.month}.${r.date.day}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    Text('${r.score.toStringAsFixed(r.score.truncateToDouble() == r.score ? 0 : 1)}점',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      color: AppColors.textSecondary,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => r.ref.delete(),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _showAddDialog(
      CollectionReference<Map<String, dynamic>> grades) async {
    final subjectCtrl = TextEditingController();
    final examCtrl = TextEditingController();
    final scoreCtrl = TextEditingController();
    DateTime date = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('성적 입력'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(
                      labelText: '과목명', hintText: '예: 국어, 수학'),
                ),
                TextField(
                  controller: examCtrl,
                  decoration: const InputDecoration(
                      labelText: '시험명 (선택)', hintText: '예: 3월 모의고사'),
                ),
                TextField(
                  controller: scoreCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: '점수'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('시험일',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date,
                          firstDate: DateTime(2015),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setLocal(() => date = picked);
                      },
                      child: Text('${date.year}.${date.month}.${date.day}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                final subject = subjectCtrl.text.trim();
                final score = double.tryParse(scoreCtrl.text.trim());
                if (subject.isEmpty || score == null) return;
                await grades.add({
                  'subject': subject,
                  'examName': examCtrl.text.trim(),
                  'score': score,
                  'date': Timestamp.fromDate(date),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ),
      );
}

class _Record {
  _Record(this.ref, this.score, this.date, this.exam, this.subject);
  final DocumentReference<Map<String, dynamic>> ref;
  final double score;
  final DateTime date;
  final String exam;
  final String subject;
}
