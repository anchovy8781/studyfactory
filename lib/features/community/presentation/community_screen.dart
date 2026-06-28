import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------
final _posts = [
  _PostData(
    avatar: '🐶',
    nickname: '공부하는강아지',
    badge: '자격증 준비중',
    badgeColor: AppColors.primary,
    content: '오늘도 전기기사 공부 완료! 회로이론이 너무 어렵지만 포기하지 않을게요 💪',
    certTag: '전기기사',
    likes: 42,
    comments: 8,
    timeAgo: '5분 전',
    isVerified: true,
  ),
  _PostData(
    avatar: '📚',
    nickname: '합격기원',
    badge: '열공중',
    badgeColor: AppColors.success,
    content: '오늘의 공부 인증! 정보처리기사 필기 마무리 했어요. 실기도 화이팅!',
    certTag: '정보처리기사',
    likes: 31,
    comments: 5,
    timeAgo: '12분 전',
    isVerified: true,
  ),
  _PostData(
    avatar: '🔥',
    nickname: '노력탄',
    badge: '스터디마스터',
    badgeColor: AppColors.accent,
    content: '7일 연속 공부 달성! 꾸준함이 답이에요 여러분. 오늘도 포기하지 말아요!',
    certTag: '공무원',
    likes: 78,
    comments: 14,
    timeAgo: '30분 전',
    isVerified: false,
  ),
  _PostData(
    avatar: '⚡',
    nickname: '집중탄갑',
    badge: '자격증 준비중',
    badgeColor: AppColors.primary,
    content: '전기기사 실기 준비 D-30. 매일 3시간씩 공부 중입니다. 같이 공부해요!',
    certTag: '전기기사',
    likes: 19,
    comments: 3,
    timeAgo: '1시간 전',
    isVerified: false,
  ),
  _PostData(
    avatar: '🌟',
    nickname: '포기란없다',
    badge: '고수',
    badgeColor: AppColors.warning,
    content: '드디어 정보처리기사 합격했어요!! 2번 만에 붙었네요 ㅠㅠ 감사합니다 여러분!',
    certTag: '정보처리기사',
    likes: 156,
    comments: 32,
    timeAgo: '2시간 전',
    isVerified: true,
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['전체', '자격증', '크루', '질문'];
  final Set<int> _likedPosts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('커뮤니티', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTextStyles.labelLarge,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeed(),
          _buildFeed(tag: '자격증'),
          const Center(child: Text('크루 탭')),
          _buildFeed(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: Text('글쓰기', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ).animate().scale(delay: 300.ms),
    );
  }

  Widget _buildFeed({String? tag}) {
    final filtered = tag == null ? _posts : _posts.where((p) => p.certTag == tag).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        return _PostCard(
          post: filtered[i],
          index: i,
          isLiked: _likedPosts.contains(i),
          onLike: () => setState(() {
            if (_likedPosts.contains(i)) {
              _likedPosts.remove(i);
            } else {
              _likedPosts.add(i);
            }
          }),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Post card widget
// ---------------------------------------------------------------------------
class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.index,
    required this.isLiked,
    required this.onLike,
  });

  final _PostData post;
  final int index;
  final bool isLiked;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
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
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(post.avatar, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(post.nickname,
                            style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        if (post.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              color: AppColors.primary, size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: post.badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        post.badge,
                        style: AppTextStyles.labelSmall.copyWith(
                            color: post.badgeColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Text(post.timeAgo,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Text(post.content,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.5)),
          const SizedBox(height: 10),
          // Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${post.certTag}',
              style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isLiked ? AppColors.error : AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likes + (isLiked ? 1 : 0)}',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: isLiked ? AppColors.error : AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 4),
                  Text('${post.comments}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 18),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).slideY(begin: 0.05);
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------
class _PostData {
  final String avatar;
  final String nickname;
  final String badge;
  final Color badgeColor;
  final String content;
  final String certTag;
  final int likes;
  final int comments;
  final String timeAgo;
  final bool isVerified;

  const _PostData({
    required this.avatar,
    required this.nickname,
    required this.badge,
    required this.badgeColor,
    required this.content,
    required this.certTag,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.isVerified,
  });
}
