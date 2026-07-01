import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/features/battle/data/battle_service.dart';

/// Live battle room: both players' study seconds update in real time.
class BattleRoomScreen extends StatefulWidget {
  const BattleRoomScreen({super.key, required this.battleId});
  final String battleId;

  @override
  State<BattleRoomScreen> createState() => _BattleRoomScreenState();
}

class _BattleRoomScreenState extends State<BattleRoomScreen> {
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  Timer? _timer;
  DateTime _segmentStart = DateTime.now();
  int _accumulated = 0; // my study seconds
  bool _paused = false;
  int _lastSynced = -1;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  int get _mySeconds =>
      _paused ? _accumulated : _accumulated + DateTime.now().difference(_segmentStart).inSeconds;

  void _tick() {
    if (mounted) setState(() {});
    final s = _mySeconds;
    // Throttle writes to ~every 3s.
    if (s != _lastSynced && s % 3 == 0) {
      _lastSynced = s;
      final isHost = _isHost;
      if (isHost != null) {
        BattleService.instance
            .updateProgress(widget.battleId, isHost: isHost, seconds: s);
      }
    }
  }

  bool? _hostCache;
  bool? get _isHost => _hostCache;

  void _togglePause() {
    setState(() {
      if (_paused) {
        _segmentStart = DateTime.now();
        _paused = false;
      } else {
        _accumulated += DateTime.now().difference(_segmentStart).inSeconds;
        _paused = true;
      }
    });
  }

  String _fmt(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text('공부 대결', style: AppTextStyles.titleLarge),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: BattleService.instance.watch(widget.battleId),
        builder: (context, snapshot) {
          final m = snapshot.data?.data();
          if (m == null) {
            return const Center(child: CircularProgressIndicator());
          }
          _hostCache = m['hostUid'] == _uid;
          final isHost = _hostCache!;
          final status = m['status'] as String? ?? 'waiting';
          final durationSec = ((m['durationMin'] as num?)?.toInt() ?? 25) * 60;
          final startedAt = (m['startedAt'] as Timestamp?)?.toDate();

          final myServerSec =
              (m[isHost ? 'hostSeconds' : 'guestSeconds'] as num?)?.toInt() ?? 0;
          final oppServerSec =
              (m[isHost ? 'guestSeconds' : 'hostSeconds'] as num?)?.toInt() ?? 0;
          final myName = (m[isHost ? 'hostName' : 'guestName'] as String?) ?? '나';
          final oppName =
              (m[isHost ? 'guestName' : 'hostName'] as String?) ?? '상대';

          // Prefer my local live count for my own bar.
          final myLive = _mySeconds > myServerSec ? _mySeconds : myServerSec;

          if (status == 'waiting') {
            return _waiting(context, isHost);
          }

          // Remaining time from the shared start.
          var remaining = durationSec;
          if (startedAt != null) {
            remaining = durationSec - DateTime.now().difference(startedAt).inSeconds;
          }
          final ended = status == 'ended' || remaining <= 0;
          if (ended && status != 'ended' && isHost) {
            BattleService.instance.endBattle(widget.battleId);
          }

          final maxSec = [myLive, oppServerSec, 1].reduce((a, b) => a > b ? a : b);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(ended ? '대결 종료' : '남은 시간 ${_fmt(remaining < 0 ? 0 : remaining)}',
                    style: AppTextStyles.titleMedium.copyWith(
                        color: ended ? AppColors.error : AppColors.primary,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                _playerBar('🟦 $myName (나)', myLive, maxSec, AppColors.primary),
                const SizedBox(height: 16),
                _playerBar('🟥 $oppName', oppServerSec, maxSec, AppColors.error),
                const SizedBox(height: 32),
                if (ended)
                  _result(myLive, oppServerSec)
                else
                  ElevatedButton.icon(
                    onPressed: _togglePause,
                    icon: Icon(_paused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded),
                    label: Text(_paused ? '다시 집중' : '잠깐 멈춤'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _paused ? AppColors.success : AppColors.textSecondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14)),
                  ),
                const SizedBox(height: 12),
                Text(_paused ? '집중이 멈춰 시간이 쌓이지 않아요' : '집중 중… 시간이 쌓이고 있어요',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _waiting(BuildContext context, bool isHost) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⏳', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(isHost ? '상대의 참가를 기다리는 중…' : '대결을 준비 중…',
              style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text('상대가 참가하면 자동으로 시작됩니다.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          if (isHost)
            TextButton(
              onPressed: () async {
                await BattleService.instance.cancelBattle(widget.battleId);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('방 취소'),
            ),
        ],
      ),
    );
  }

  Widget _playerBar(String name, int seconds, int maxSec, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700)),
            Text(_fmt(seconds),
                style: AppTextStyles.titleSmall
                    .copyWith(color: color, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (seconds / maxSec).clamp(0.0, 1.0),
            minHeight: 14,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _result(int mine, int opp) {
    final win = mine > opp;
    final tie = mine == opp;
    return Column(
      children: [
        Text(tie ? '🤝' : (win ? '🏆' : '😢'),
            style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 8),
        Text(tie ? '무승부!' : (win ? '승리!' : '패배'),
            style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: tie
                    ? AppColors.textSecondary
                    : (win ? AppColors.success : AppColors.error))),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('나가기'),
        ),
      ],
    );
  }
}
