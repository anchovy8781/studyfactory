/// Lightweight content moderation for community posts/comments.
///
/// Blocks obvious profanity/abuse. Not exhaustive — a server-side filter is
/// recommended for production, but this catches common cases on-device.
class ContentFilter {
  static const _banned = <String>[
    '시발', '씨발', '씨바', 'ㅅㅂ', 'ㅆㅂ', '개새끼', '새끼', '병신', 'ㅂㅅ',
    '지랄', '좆', '존나', 'ㅈㄴ', '미친놈', '미친년', '닥쳐', '꺼져',
    '엿먹', '죽어', '꼴값', '창녀', '걸레', '쓰레기야',
    'fuck', 'shit', 'bitch', 'asshole',
  ];

  /// Returns the first banned word found, or null if the text is clean.
  static String? findBanned(String text) {
    final lower = text.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    for (final w in _banned) {
      if (lower.contains(w.toLowerCase())) return w;
    }
    return null;
  }

  static bool isClean(String text) => findBanned(text) == null;

  /// Masks banned words with asterisks (for display fallback).
  static String mask(String text) {
    var out = text;
    for (final w in _banned) {
      out = out.replaceAll(
        RegExp(RegExp.escape(w), caseSensitive: false),
        '*' * w.length,
      );
    }
    return out;
  }
}
