import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';

class MyInfoScreen extends ConsumerStatefulWidget {
  const MyInfoScreen({super.key});

  @override
  ConsumerState<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends ConsumerState<MyInfoScreen> {
  final _nicknameController = TextEditingController(text: '김스터디');
  final _schoolController = TextEditingController(text: '한국전자통신연구원');
  bool _isEditing = false;

  final _targetSubjects = ['전기기사', '정보처리기사'];
  final _allSubjects = ['전기기사', '정보처리기사', '공무원', '토익', '리눅스마스터', '정보보안기사'];

  @override
  void dispose() {
    _nicknameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('내 정보', style: AppTextStyles.titleLarge),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(_isEditing ? '완료' : '편집',
                style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 20),
            _buildInfoSection(),
            const SizedBox(height: 20),
            _buildSubjectsSection(),
            const SizedBox(height: 30),
            if (_isEditing)
              AppButton(
                label: '변경사항 저장',
                onPressed: () => setState(() => _isEditing = false),
              ).animate().fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.cardShadow,
                ),
                child: const Center(child: Text('🐶', style: TextStyle(fontSize: 50))),
              ),
              if (_isEditing)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: Text('프로필 사진 변경',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildInfoField(
            label: '닉네임',
            controller: _nicknameController,
            enabled: _isEditing,
            icon: Icons.person_rounded,
          ),
          const Divider(color: AppColors.divider, height: 20),
          _buildReadOnlyField(
            label: '이메일',
            value: 'pjw8781@gmail.com',
            icon: Icons.email_outlined,
          ),
          const Divider(color: AppColors.divider, height: 20),
          _buildInfoField(
            label: '소속 / 학교',
            controller: _schoolController,
            enabled: _isEditing,
            icon: Icons.school_outlined,
          ),
          const Divider(color: AppColors.divider, height: 20),
          _buildReadOnlyField(
            label: '가입일',
            value: '2024년 1월 15일',
            icon: Icons.calendar_today_outlined,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              enabled
                  ? TextField(
                      controller: controller,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: '입력하세요',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary),
                      ),
                    )
                  : Text(controller.text,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(value,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsSection() {
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
            children: [
              const Icon(Icons.bookmark_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('목표 과목',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allSubjects.map((s) {
              final selected = _targetSubjects.contains(s);
              return GestureDetector(
                onTap: _isEditing
                    ? () {
                        setState(() {
                          if (selected) {
                            _targetSubjects.remove(s);
                          } else {
                            _targetSubjects.add(s);
                          }
                        });
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      )),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }
}
