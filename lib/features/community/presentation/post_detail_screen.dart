import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/utils/content_filter.dart';
import 'package:studyverse/features/community/presentation/community_screen.dart'
    show reportPost, resolveUserName;

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
  String? _replyToId; // 대댓글 대상 댓글 id
  String? _replyToName;

  void _startReply(String commentId, String name) {
    setState(() {
      _replyToId = commentId;
      _replyToName = name;
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() {
      _replyToId = null;
      _replyToName = null;
    });
  }

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
    if (!ContentFilter.isClean(text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('부적절한 표현이 포함되어 있어 등록할 수 없습니다.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _sending = true);
    try {
      final authorName = await resolveUserName();
      await _comments.add({
        'authorId': user.uid,
        'authorName': authorName,
        'content': text,
        'parentId': _replyToId, // null = 일반 댓글, 값 있으면 대댓글
        'createdAt': FieldValue.serverTimestamp(),
      });
      await widget.postRef
          .update({'commentCount': FieldValue.increment(1)}).catchError((_) {});
      _commentCtrl.clear();
      setState(() {
        _replyToId = null;
        _replyToName = null;
      });
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

  Future<void> _reportPost() async {
    final reasons = ['스팸/광고', '욕설/비방', '음란물', '허위정보', '기타'];
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('신고 사유를 선택하세요',
                  style: AppTextStyles.titleSmall),
            ),
            ...reasons.map((r) => ListTile(
                  title: Text(r),
                  onTap: () => Navigator.of(ctx).pop(r),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (reason == null) return;
    try {
      await reportPost(widget.postRef, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('신고가 접수되었습니다.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('신고 실패: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
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
              Row(
                children: [
                  Expanded(
                    child: Text((m['authorName'] as String?) ?? '익명',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, size: 20),
                    color: AppColors.textSecondary,
                    tooltip: '신고',
                    onPressed: () => _reportPost(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text((m['content'] as String?) ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
              if ((m['imageUrl'] as String?)?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Image.network(
                    m['imageUrl'] as String,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : const SizedBox(
                                height: 180,
                                child:
                                    Center(child: CircularProgressIndicator())),
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
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
        // 대댓글: parentId가 없으면 일반 댓글, 있으면 해당 댓글의 답글.
        final topLevel = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final repliesByParent =
            <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
        for (final d in docs) {
          final parent = d.data()['parentId'] as String?;
          if (parent == null || parent.isEmpty) {
            topLevel.add(d);
          } else {
            repliesByParent.putIfAbsent(parent, () => []).add(d);
          }
        }
        return Column(
          children: topLevel.map((d) {
            final replies = repliesByParent[d.id] ?? const [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _commentTile(d, isReply: false),
                ...replies.map((r) => _commentTile(r, isReply: true)),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _commentTile(QueryDocumentSnapshot<Map<String, dynamic>> d,
      {required bool isReply}) {
    final c = d.data();
    return Container(
      margin: EdgeInsets.only(bottom: 8, left: isReply ? 28 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReply ? AppColors.surfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isReply)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.subdirectory_arrow_right_rounded,
                      size: 14, color: AppColors.textSecondary),
                ),
              Text((c['authorName'] as String?) ?? '익명',
                  style: AppTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 2),
          Text((c['content'] as String?) ?? '',
              style: AppTextStyles.bodyMedium),
          if (!isReply)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    _startReply(d.id, (c['authorName'] as String?) ?? '익명'),
                icon: const Icon(Icons.reply_rounded, size: 14),
                label: const Text('답글'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyToId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Row(
                  children: [
                    const Icon(Icons.reply_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('$_replyToName 님에게 답글 작성 중',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.primary)),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText:
                          _replyToId != null ? '답글을 입력하세요' : '댓글을 입력하세요',
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
          ],
        ),
      ),
    );
  }
}
