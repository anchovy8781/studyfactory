import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/utils/content_filter.dart';
import 'package:studyverse/features/community/presentation/post_detail_screen.dart';

enum _Sort { latest, oldest, popular, comments }

extension on _Sort {
  String get label => switch (this) {
        _Sort.latest => '최신순',
        _Sort.oldest => '날짜순',
        _Sort.popular => '인기순',
        _Sort.comments => '댓글순',
      };
}

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  _Sort _sort = _Sort.latest;
  String _query = '';

  CollectionReference<Map<String, dynamic>> get _posts =>
      FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('커뮤니티', style: AppTextStyles.titleLarge),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/community/write'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text('글쓰기', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSortChips(),
          Expanded(child: _buildPostList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
        decoration: InputDecoration(
          isDense: true,
          hintText: '키워드로 검색 (내용·닉네임·태그)',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _Sort.values.map((s) {
          final selected = s == _sort;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(s.label),
              selected: selected,
              onSelected: (_) => setState(() => _sort = s),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              backgroundColor: AppColors.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Query<Map<String, dynamic>> _sortedQuery() {
    switch (_sort) {
      case _Sort.latest:
        return _posts.orderBy('createdAt', descending: true);
      case _Sort.oldest:
        return _posts.orderBy('createdAt', descending: false);
      case _Sort.popular:
        return _posts.orderBy('likes', descending: true);
      case _Sort.comments:
        return _posts.orderBy('commentCount', descending: true);
    }
  }

  Widget _buildPostList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _sortedQuery().snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _empty('게시글을 불러올 수 없습니다.\nFirestore 규칙에 posts 컬렉션 권한을 추가하세요.');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snapshot.data!.docs;
        // 검열: 신고 3회 이상 게시글 숨김
        docs = docs
            .where((d) => ((d.data()['reportCount'] as num?)?.toInt() ?? 0) < 3)
            .toList();
        if (_query.isNotEmpty) {
          docs = docs.where((d) {
            final m = d.data();
            final hay =
                '${m['content'] ?? ''} ${m['authorName'] ?? ''} ${m['certTag'] ?? ''}'
                    .toLowerCase();
            return hay.contains(_query);
          }).toList();
        }
        if (docs.isEmpty) {
          return _empty(_query.isEmpty
              ? '아직 게시글이 없어요.\n첫 글을 작성해보세요!'
              : '검색 결과가 없습니다.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _PostCard(doc: docs[i]),
        );
      },
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

class _PostCard extends StatelessWidget {
  const _PostCard({required this.doc});
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  @override
  Widget build(BuildContext context) {
    final m = doc.data();
    final name = (m['authorName'] as String?) ?? '익명';
    final content = (m['content'] as String?) ?? '';
    final imageUrl = (m['imageUrl'] as String?) ?? '';
    final tag = (m['certTag'] as String?) ?? '';
    final likes = (m['likes'] as num?)?.toInt() ?? 0;
    final comments = (m['commentCount'] as num?)?.toInt() ?? 0;
    final ts = (m['createdAt'] as Timestamp?)?.toDate();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final likedBy =
        ((m['likedBy'] as List?) ?? const []).map((e) => e.toString()).toSet();
    final liked = uid != null && likedBy.contains(uid);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PostDetailScreen(postRef: doc.reference),
      )),
      child: Container(
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
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryContainer,
                child: Text(name.isNotEmpty ? name.substring(0, 1) : '?',
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    Text(_timeAgo(ts),
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (tag.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(tag,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primary)),
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    size: 20, color: AppColors.textSecondary),
                onSelected: (v) {
                  if (v == 'report') _showReportSheet(context);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('신고하기'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
          if (imageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        height: 160,
                        child: Center(child: CircularProgressIndicator())),
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _action(
                icon: liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: liked ? AppColors.error : null,
                count: likes,
                onTap: uid == null ? null : () => _toggleLike(uid, liked),
              ),
              const SizedBox(width: 20),
              _action(
                  icon: Icons.chat_bubble_outline_rounded, count: comments),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _showReportSheet(BuildContext context) async {
    const reasons = ['스팸/광고', '욕설/비방', '음란물', '허위정보', '기타'];
    final messenger = ScaffoldMessenger.of(context);
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
              child: Text('신고 사유를 선택하세요', style: AppTextStyles.titleSmall),
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
      await reportPost(doc.reference, reason);
      messenger.showSnackBar(const SnackBar(
        content: Text('신고가 접수되었습니다.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('신고 실패: $e'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _toggleLike(String uid, bool liked) async {
    try {
      await doc.reference.update({
        'likes': FieldValue.increment(liked ? -1 : 1),
        'likedBy':
            liked ? FieldValue.arrayRemove([uid]) : FieldValue.arrayUnion([uid]),
      });
    } catch (_) {/* ignore */}
  }

  Widget _action(
      {required IconData icon,
      required int count,
      VoidCallback? onTap,
      Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 4),
          Text('$count',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  String _timeAgo(DateTime? t) {
    if (t == null) return '방금 전';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}

/// Helper used by the write screen to publish a post.
Future<void> createPost(String content, String certTag,
    {String? imageUrl}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw '로그인이 필요합니다.';
  final banned = ContentFilter.findBanned(content);
  if (banned != null) {
    throw '부적절한 표현이 포함되어 있어 등록할 수 없습니다.';
  }
  await FirebaseFirestore.instance.collection('posts').add({
    'authorId': user.uid,
    'authorName': user.displayName ?? '익명',
    'content': content.trim(),
    'certTag': certTag.trim(),
    if (imageUrl != null) 'imageUrl': imageUrl,
    'likes': 0,
    'commentCount': 0,
    'reportCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

/// Report a post (writes to `reports`; hides it after enough reports).
Future<void> reportPost(
    DocumentReference<Map<String, dynamic>> postRef, String reason) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw '로그인이 필요합니다.';
  await FirebaseFirestore.instance.collection('reports').add({
    'postId': postRef.id,
    'reporterId': user.uid,
    'reason': reason,
    'createdAt': FieldValue.serverTimestamp(),
  });
  await postRef.update({'reportCount': FieldValue.increment(1)});
}
