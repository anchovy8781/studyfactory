import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';

class MyInfoScreen extends ConsumerStatefulWidget {
  const MyInfoScreen({super.key});

  @override
  ConsumerState<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends ConsumerState<MyInfoScreen> {
  final _nicknameController = TextEditingController();
  final _schoolController = TextEditingController();
  bool _isEditing = false;
  bool _saving = false;
  String? _photoPath;

  final _targetSubjects = <String>[];
  final _allSubjects = ['전기기사', '정보처리기사', '공무원', '토익', '리눅스마스터', '정보보안기사'];

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = _user?.displayName ?? '';
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _photoPath = prefs.getString('profile_photo_path');
    final uid = _user?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final d = doc.data();
        if (d != null) {
          _schoolController.text = (d['school'] as String?) ?? '';
          final subs = (d['targetSubjects'] as List?) ?? const [];
          _targetSubjects
            ..clear()
            ..addAll(subs.map((e) => e.toString()));
        }
      } catch (_) {/* offline / locked */}
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 80,
    );
    if (picked == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_photo_path', picked.path);
    if (mounted) setState(() => _photoPath = picked.path);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _user?.updateDisplayName(_nicknameController.text.trim());
      final uid = _user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'nickname': _nicknameController.text.trim(),
          'school': _schoolController.text.trim(),
          'targetSubjects': _targetSubjects,
        }, SetOptions(merge: true));
      }
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('저장되었습니다.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _joinDate() {
    final t = _user?.metadata.creationTime;
    if (t == null) return '-';
    return '${t.year}년 ${t.month}월 ${t.day}일';
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
            onPressed: () {
              if (_isEditing) {
                _save();
              } else {
                setState(() => _isEditing = true);
              }
            },
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
                isLoading: _saving,
                onPressed: _saving ? null : _save,
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
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.cardShadow,
                  image: _photoPath != null && File(_photoPath!).existsSync()
                      ? DecorationImage(
                          image: FileImage(File(_photoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _photoPath != null && File(_photoPath!).existsSync()
                    ? null
                    : const Center(
                        child: Icon(Icons.person_rounded,
                            color: Colors.white, size: 52),
                      ),
              ),
              if (_isEditing)
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: _pickPhoto,
              child: Text('프로필 사진 변경',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
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
            value: _user?.email ?? '-',
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
            value: _joinDate(),
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
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              enabled
                  ? TextField(
                      controller: controller,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: '입력하세요',
                        hintStyle: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    )
                  : Text(controller.text.isEmpty ? '-' : controller.text,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
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
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(value,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
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
              const Icon(Icons.bookmark_outline_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('목표 과목',
                  style:
                      AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (_isEditing)
                Text('탭하여 선택',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        selected ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w400,
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
