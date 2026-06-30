import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyverse/core/services/notification_service.dart';
import 'package:studyverse/core/theme/theme_mode_provider.dart';
import 'package:studyverse/features/auth/presentation/providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final _notificationsProvider = StateProvider<bool>((ref) => true);
final _studyReminderProvider = StateProvider<bool>((ref) => false);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(_notificationsProvider);
    final darkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final studyReminder = ref.watch(_studyReminderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('설정', style: AppTextStyles.titleLarge),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSection(
            title: '알림',
            delay: 0,
            children: [
              _buildToggleTile(
                icon: Icons.notifications_outlined,
                iconColor: AppColors.primary,
                title: '알림 설정',
                subtitle: '앱 알림 허용',
                value: notifications,
                onChanged: (v) {
                  ref.read(_notificationsProvider.notifier).state = v;
                  NotificationService.instance.setEnabled(v);
                },
              ),
              _buildToggleTile(
                icon: Icons.alarm_rounded,
                iconColor: AppColors.accent,
                title: '공부 리마인더',
                subtitle: '원하는 시간에 매일 학습 알림',
                value: studyReminder,
                onChanged: (v) async {
                  ref.read(_studyReminderProvider.notifier).state = v;
                  if (v) {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 20, minute: 0),
                      helpText: '리마인더 시간 선택',
                    );
                    if (t != null) {
                      await NotificationService.instance
                          .scheduleDailyReminder(t.hour, t.minute);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '매일 ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}에 알림을 보냅니다.'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } else {
                      ref.read(_studyReminderProvider.notifier).state = false;
                    }
                  } else {
                    await NotificationService.instance.cancelDailyReminder();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: '화면',
            delay: 60,
            children: [
              _buildToggleTile(
                icon: Icons.dark_mode_outlined,
                iconColor: const Color(0xFF3F51B5),
                title: '다크 모드',
                subtitle: '어두운 테마 사용',
                value: darkMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setDark(v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: '학습',
            delay: 120,
            children: [
              _buildNavTile(
                context: context,
                icon: Icons.flag_outlined,
                iconColor: AppColors.success,
                title: '학습 목표 설정',
                subtitle: '하루 목표 공부 시간 설정',
                onTap: () => _showGoalDialog(context),
              ),
              _buildNavTile(
                context: context,
                icon: Icons.subject_rounded,
                iconColor: AppColors.warning,
                title: '과목 관리',
                subtitle: '공부 과목 추가 및 삭제',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: '개인정보',
            delay: 180,
            children: [
              _buildNavTile(
                context: context,
                icon: Icons.lock_outline_rounded,
                iconColor: AppColors.textSecondary,
                title: '비밀번호 변경',
                subtitle: '재설정 이메일 받기',
                onTap: () => context.push('/forgot-password'),
              ),
              _buildNavTile(
                context: context,
                icon: Icons.policy_outlined,
                iconColor: AppColors.textSecondary,
                title: '개인정보 처리방침',
                onTap: () => context.push('/privacy'),
              ),
              _buildNavTile(
                context: context,
                icon: Icons.description_outlined,
                iconColor: AppColors.textSecondary,
                title: '이용약관',
                onTap: () => context.push('/terms'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: '고객지원',
            delay: 240,
            children: [
              _buildNavTile(
                context: context,
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.primary,
                title: '문의하기',
                subtitle: '자주 묻는 질문 및 1:1 문의',
                onTap: () => context.push('/support'),
              ),
              _buildVersionTile(),
            ],
          ),
          const SizedBox(height: 16),
          _buildDangerSection(context, ref),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Section wrapper ──────────────────────────────────────────────────────
  Widget _buildSection({
    required String title,
    required List<Widget> children,
    int delay = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: List.generate(children.length, (i) {
              return Column(
                children: [
                  children[i],
                  if (i < children.length - 1)
                    const Divider(height: 1, color: AppColors.divider, indent: 66),
                ],
              );
            }),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: delay.ms),
      ],
    );
  }

  // ── Toggle tile ──────────────────────────────────────────────────────────
  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(subtitle,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // ── Nav tile ─────────────────────────────────────────────────────────────
  Widget _buildNavTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('준비 중인 기능입니다.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Version tile ─────────────────────────────────────────────────────────
  Widget _buildVersionTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('버전 정보',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Text('v1.0.0',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ── Danger section ───────────────────────────────────────────────────────
  Widget _buildDangerSection(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _showLogoutDialog(context, ref),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Text('로그아웃',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider, indent: 52),
          InkWell(
            onTap: () => _showWithdrawDialog(context, ref),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.delete_forever_outlined,
                      color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Text('회원 탈퇴',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: Text('로그아웃',
                style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showGoalDialog(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    double goal = 5;
    final textCtrl = TextEditingController(text: '5');
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('하루 목표 공부 시간'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Direct numeric input (0.5h steps supported).
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: textCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: AppColors.primary),
                      decoration: const InputDecoration(
                          isDense: true, border: OutlineInputBorder()),
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        if (parsed != null) {
                          setLocal(() => goal = parsed.clamp(0.5, 24.0));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('시간', style: AppTextStyles.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: goal.clamp(1, 16),
                min: 1,
                max: 16,
                divisions: 30,
                label: '${goal.toStringAsFixed(1)}시간',
                onChanged: (v) => setLocal(() {
                  goal = v;
                  textCtrl.text =
                      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                if (uid != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .set({'targetHours': goal}, SetOptions(merge: true));
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('하루 목표를 ${goal.toStringAsFixed(1)}시간으로 설정했습니다.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true, // tap outside to close
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('회원 탈퇴'),
        content: const Text(
            '계정을 삭제하면 모든 학습 데이터가 영구적으로 삭제됩니다.\n'
            '탈퇴 후 30일간 같은 기기에서 재가입이 제한됩니다.\n'
            '정말 탈퇴하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('닫기',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(authProvider.notifier).withdraw();
                if (context.mounted) context.go('/login');
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('탈퇴',
                style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
