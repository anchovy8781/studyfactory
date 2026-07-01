import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/features/battle/data/battle_service.dart';
import 'package:studyverse/features/battle/presentation/battle_room_screen.dart';

/// Lobby for the real-time study battle: create a room or join an open one.
class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  Future<void> _create(BuildContext context) async {
    final duration = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('대결 시간을 선택하세요'),
            ),
            ...[15, 25, 30, 60].map((m) => ListTile(
                  title: Text('$m분 대결'),
                  onTap: () => Navigator.pop(ctx, m),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (duration == null) return;
    try {
      final id = await BattleService.instance.createBattle(durationMin: duration);
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => BattleRoomScreen(battleId: id)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text('실시간 공부 대결', style: AppTextStyles.titleLarge),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('대결방 만들기', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFB91C1C)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('⚔️', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('친구와 실시간으로 공부 시간을 대결하세요!\n정해진 시간 동안 더 오래 집중한 사람이 승리 🏆',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('참가 대기 중인 방',
                  style: AppTextStyles.titleSmall),
            ),
          ),
          Expanded(
            child: StreamBuilder<
                List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: BattleService.instance.watchOpen(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _empty('대결방을 불러올 수 없습니다.\nFirestore 규칙에 battles 권한을 추가하세요.');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!;
                if (docs.isEmpty) {
                  return _empty('열려 있는 대결방이 없어요.\n방을 만들어 상대를 기다려보세요!');
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final m = docs[i].data();
                    final mine = m['hostUid'] == myUid;
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${m['hostName'] ?? '호스트'} 님의 방',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700)),
                                Text('${m['durationMin']}분 대결',
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final nav = Navigator.of(context);
                              try {
                                if (!mine) {
                                  await BattleService.instance
                                      .joinBattle(docs[i].id);
                                }
                                nav.push(MaterialPageRoute<void>(
                                    builder: (_) => BattleRoomScreen(
                                        battleId: docs[i].id)));
                              } catch (e) {
                                messenger.showSnackBar(
                                    SnackBar(content: Text('$e')));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: mine
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                                foregroundColor: Colors.white),
                            child: Text(mine ? '입장' : '참가'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
