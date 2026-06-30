import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide theme mode (light/dark/system), persisted on device.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  static const _key = 'theme_mode';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    switch (p.getString(_key)) {
      case 'dark':
        state = ThemeMode.dark;
      case 'light':
        state = ThemeMode.light;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _key,
      switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      },
    );
  }

  Future<void> setDark(bool dark) =>
      set(dark ? ThemeMode.dark : ThemeMode.light);
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
