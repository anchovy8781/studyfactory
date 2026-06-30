import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// Post detail with a comment thread (view + write).
class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postRef});

  final DocumentReference<Map<String, dynamic>> postRef;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentCtrl = TextEditingController();
  bool _sending = false;

  CollectionReference<Map<String, dynamic>> get _comments =>
      widget.postRef.collection('comments');

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _commentCtrl.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (text.isEmpty || user == null) return;
    setState(() => _sending = true);
    try {
      await _comments.add({
        'authorId': user.uid,
        'authorName': user.displayName ?? '익명',
        'content': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await widget.postRef
          .update({'commentCount': FieldValue.increment(1)}).catchError((_) {});
      _commentCtrl.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 등록 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('게시글'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
              children: [
                _buildPost(),
                const SizedBox(height: AppSizes.spaceLg),
                Text('댓글', style: AppTextStyles.titleSmall),
                const SizedBox(height: AppSizes.spaceSm),
                _buildComments(),
              ],
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildPost() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: widget.postRef.snapshots(),
      builder: (context, snapshot) {
        final m = snapshot.data?.data();
        if (m == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(AppSizes.spaceLg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((m['authorName'] as String?) ?? '익명',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text((m['content'] as String?) ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComments() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _comments.orderBy('createdAt', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('댓글을 불러올 수 없습니다.\nFirestore 규칙에 comments 권한을 추가하세요.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('첫 댓글을 남겨보세요!',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ),
          );
        }
        return Column(
          children: docs.map((d) {
            final c = d.data();
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((c['authorName'] as String?) ?? '익명',
                      style: AppTextStyles.labelMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text((c['content'] as String?) ?? '',
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentCtrl,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '댓글을 입력하세요',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: AppColors.primary),
              onPressed: _sending ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
