import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------
final _mentors = [
  _MentorData(
    avatar: '👨‍🏫',
    name: '박전기',
    title: '전기기사 1회 합격',
    rating: 4.9,
    reviewCount: 48,
    subjects: ['전기기사', '전기산업기사', '회로이론'],
    experience: '5년',
    bio: '전기기사 1회 합격 후 현재 한국전력 근무 중. 회로이론, 전력공학 중점 지도.',
    price: '무료',
    isOnline: true,
  ),
  _MentorData(
    avatar: '👩‍💻',
    name: '이코딩',
    title: '정보처리기사 전문 멘토',
    rating: 4.8,
    reviewCount: 33,
    subjects: ['정보처리기사', '리눅스마스터', 'SQL'],
    experience: '3년',
    bio: 'IT 기업 현직 개발자. 정보처리기사 필기·실기 단기 합격 전략 전수.',
    price: '무료',
    isOnline: false,
  ),
  _MentorData(
    avatar: '🎓',
    name: '최합격',
    title: '공무원 합격 멘토',
    rating: 4.7,
    reviewCount: 61,
    subjects: ['9급 공무원', '행정학', '국어'],
    experience: '2년',
    bio: '9급 행정직 현직 공무원. 효율적인 공부법과 마인드셋 코칭.',
    price: '무료',
    isOnline: true,
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class MentorScreen extends ConsumerStatefulWidget {
  const MentorScreen({super.key});

  @override
  ConsumerState<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends ConsumerState<MentorScreen> {
  String _selectedSubject = '전체';
  final _subjects = ['전체', '전기기사', '정보처리기사', '공무원', '토익'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('멘토 찾기', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSubjectFilter(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _mentors.length,
              itemBuilder: (context, i) {
                return _MentorCard(mentor: _mentors[i], index: i);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('합격 경험을 나눠드려요',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('선배 합격자에게 공부 노하우를 물어보세요',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSubjectFilter() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _subjects.map((s) {
            final selected = s == _selectedSubject;
            return GestureDetector(
              onTap: () => setState(() => _selectedSubject = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mentor card
// ---------------------------------------------------------------------------
class _MentorCard extends StatefulWidget {
  const _MentorCard({required this.mentor, required this.index});

  final _MentorData mentor;
  final int index;

  @override
  State<_MentorCard> createState() => _MentorCardState();
}

class _MentorCardState extends State<_MentorCard> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.mentor;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(m.avatar, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  if (m.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name,
                        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                    Text(m.title,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                        const SizedBox(width: 3),
                        Text('${m.rating}',
                            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 3),
                        Text('(${m.reviewCount}개)',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(m.isOnline ? '온라인' : '오프라인',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: m.isOnline ? AppColors.success : AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(m.price,
                      style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(m.bio,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: m.subjects.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _requested = !_requested),
              style: ElevatedButton.styleFrom(
                backgroundColor: _requested ? AppColors.surfaceVariant : AppColors.primary,
                foregroundColor: _requested ? AppColors.textSecondary : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(
                _requested ? '신청 완료' : '멘토 신청',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (widget.index * 80).ms).slideY(begin: 0.05);
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------
class _MentorData {
  final String avatar;
  final String name;
  final String title;
  final double rating;
  final int reviewCount;
  final List<String> subjects;
  final String experience;
  final String bio;
  final String price;
  final bool isOnline;

  const _MentorData({
    required this.avatar,
    required this.name,
    required this.title,
    required this.rating,
    required this.reviewCount,
    required this.subjects,
    required this.experience,
    required this.bio,
    required this.price,
    required this.isOnline,
  });
}
