import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// Royalty-free focus-sound player.
///
/// All tracks are synthesized noise bundled with the app, so they are fully
/// copyright-free. Each loops seamlessly while studying.
class FocusMusicScreen extends StatefulWidget {
  const FocusMusicScreen({super.key});

  @override
  State<FocusMusicScreen> createState() => _FocusMusicScreenState();
}

class _Track {
  const _Track(this.title, this.desc, this.emoji, this.asset, this.color);
  final String title;
  final String desc;
  final String emoji;
  final String asset;
  final Color color;
}

class _FocusMusicScreenState extends State<FocusMusicScreen> {
  static const _tracks = [
    _Track('갈색 소음', '깊고 부드러운 저음 — 집중에 가장 인기', '🟤',
        'audio/brown_noise.wav', Color(0xFF6D4C41)),
    _Track('백색 소음', '균일한 소음으로 주변 소리 차단', '⚪',
        'audio/white_noise.wav', Color(0xFF607D8B)),
    _Track('핑크 소음', '편안하고 균형 잡힌 소음', '🌸',
        'audio/pink_noise.wav', Color(0xFFEC407A)),
    _Track('빗소리', '잔잔한 빗소리로 마음 안정', '🌧',
        'audio/rain.wav', Color(0xFF42A5F5)),
  ];

  final _player = AudioPlayer();
  int? _playingIndex;
  double _volume = 0.7;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.loop);
    _player.setVolume(_volume);
  }

  @override
  void dispose() {
    _player.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _toggle(int index) async {
    if (_playingIndex == index) {
      await _player.pause();
      await WakelockPlus.disable();
      setState(() => _playingIndex = null);
      return;
    }
    try {
      await _player.stop();
      await _player.play(AssetSource(_tracks[index].asset), volume: _volume);
      await WakelockPlus.enable();
      setState(() => _playingIndex = index);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('재생할 수 없습니다: $e')),
        );
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
        centerTitle: true,
        title: Text('집중 음악', style: AppTextStyles.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5E35B1), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎧', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text('무저작권 집중 사운드',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('앱에 내장된 저작권 걱정 없는 소리로\n공부에 몰입해보세요.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.volume_up_rounded,
                  size: 20, color: AppColors.textSecondary),
              Expanded(
                child: Slider(
                  value: _volume,
                  onChanged: (v) {
                    setState(() => _volume = v);
                    _player.setVolume(v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._tracks.asMap().entries.map((e) {
            final i = e.key;
            final t = e.value;
            final playing = _playingIndex == i;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: playing ? t.color.withOpacity(0.10) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: playing ? t.color : AppColors.border,
                    width: playing ? 1.6 : 1),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Text(t.emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title,
                            style: AppTextStyles.bodyLarge
                                .copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(t.desc,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    iconSize: 44,
                    color: t.color,
                    icon: Icon(playing
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded),
                    onPressed: () => _toggle(i),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
