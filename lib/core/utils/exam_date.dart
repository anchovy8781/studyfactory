/// Parses a loosely-formatted Korean date string (e.g. "2026년 9월 15일",
/// "2026-09-15", "2026년8월") into a [DateTime], or null if unparseable.
DateTime? parseKoreanDate(String input) {
  final nums = RegExp(r'\d+')
      .allMatches(input)
      .map((m) => int.parse(m.group(0)!))
      .toList();
  if (nums.isEmpty) return null;
  var year = nums[0];
  final month = nums.length > 1 ? nums[1] : 1;
  final day = nums.length > 2 ? nums[2] : 1;
  if (year < 100) year += 2000;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  try {
    return DateTime(year, month, day);
  } catch (_) {
    return null;
  }
}

/// True when [input] clearly refers to a date before today.
bool isExamDatePast(String input) {
  final d = parseKoreanDate(input);
  if (d == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return d.isBefore(today);
}
