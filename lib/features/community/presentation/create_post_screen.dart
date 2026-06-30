import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/features/community/presentation/community_screen.dart'
    show createPost;

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentCtrl = TextEditingController();
  final _tags = ['전기기사', '정보처리기사', '공무원', '토익', '수능', '기타'];
  String _tag = '전기기사';
  bool _posting = false;
  File? _image;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (picked != null) setState(() => _image = File(picked.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지를 불러올 수 없습니다: $e')),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    final file = _image;
    if (file == null) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    final ref = FirebaseStorage.instance.ref(
      'post_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (_contentCtrl.text.trim().isEmpty) return;
    setState(() => _posting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final imageUrl = await _uploadImage();
      await createPost(_contentCtrl.text, _tag, imageUrl: imageUrl);
      if (mounted) {
        messenger.showSnackBar(const SnackBar(
          content: Text('게시글이 등록되었습니다.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        context.pop();
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('글쓰기'),
        actions: [
          TextButton(
            onPressed: _posting ? null : _submit,
            child: Text('등록',
                style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('태그', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags.map((t) {
                  final sel = t == _tag;
                  return ChoiceChip(
                    label: Text(t),
                    selected: sel,
                    onSelected: (_) => setState(() => _tag = t),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : AppColors.textSecondary),
                    backgroundColor: AppColors.surfaceVariant,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.spaceLg),
              Expanded(
                child: TextField(
                  controller: _contentCtrl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: '오늘의 공부 인증, 응원, 질문을 자유롭게 남겨보세요!',
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_image != null) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      child: Image.file(
                        _image!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _image = null),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _posting ? null : _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('사진 첨부'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary),
                ),
              ),
              if (_posting)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
