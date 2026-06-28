/// Form field validator functions for StudyVerse.
/// Each function returns null when valid, or an error string when invalid.
abstract final class Validators {
  // ── Auth ──────────────────────────────────────────────────────────────────

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요.';
    }
    final trimmed = value.trim();
    if (!RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(trimmed)) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return '비밀번호는 영문자를 포함해야 합니다.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return '비밀번호는 숫자를 포함해야 합니다.';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '비밀번호를 다시 입력해주세요.';
      }
      if (value != originalPassword) {
        return '비밀번호가 일치하지 않습니다.';
      }
      return null;
    };
  }

  static String? nickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '닉네임을 입력해주세요.';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return '닉네임은 2자 이상이어야 합니다.';
    }
    if (trimmed.length > 20) {
      return '닉네임은 20자 이하여야 합니다.';
    }
    if (!RegExp(r'^[가-힣a-zA-Z0-9_]+$').hasMatch(trimmed)) {
      return '닉네임은 한글, 영문, 숫자, 언더스코어만 사용 가능합니다.';
    }
    return null;
  }

  // ── Required / General ────────────────────────────────────────────────────

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName을 입력해주세요.' : '필수 항목입니다.';
    }
    return null;
  }

  static String? Function(String?) minLength(
    int min, {
    String? message,
  }) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < min) {
        return message ?? '최소 $min자 이상 입력해주세요.';
      }
      return null;
    };
  }

  static String? Function(String?) maxLength(
    int max, {
    String? message,
  }) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (value.length > max) {
        return message ?? '최대 $max자까지 입력 가능합니다.';
      }
      return null;
    };
  }

  // ── Numeric ───────────────────────────────────────────────────────────────

  static String? positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName을 입력해주세요.' : '숫자를 입력해주세요.';
    }
    final number = num.tryParse(value.trim());
    if (number == null) return '숫자만 입력 가능합니다.';
    if (number <= 0) return '0보다 큰 숫자를 입력해주세요.';
    return null;
  }

  static String? Function(String?) range(num min, num max) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      final number = num.tryParse(value);
      if (number == null) return '숫자만 입력 가능합니다.';
      if (number < min || number > max) {
        return '$min ~ $max 사이의 값을 입력해주세요.';
      }
      return null;
    };
  }

  // ── Phone ─────────────────────────────────────────────────────────────────

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '전화번호를 입력해주세요.';
    }
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10 || digits.length > 11) {
      return '올바른 전화번호 형식이 아닙니다.';
    }
    return null;
  }

  // ── URL ───────────────────────────────────────────────────────────────────

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || (!uri.hasScheme) || uri.host.isEmpty) {
      return '올바른 URL 형식이 아닙니다.';
    }
    return null;
  }

  // ── Study specific ────────────────────────────────────────────────────────

  static String? studyGoalMinutes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '목표 시간을 입력해주세요.';
    }
    final minutes = int.tryParse(value.trim());
    if (minutes == null) return '숫자만 입력 가능합니다.';
    if (minutes < 1) return '최소 1분 이상 설정해주세요.';
    if (minutes > 1440) return '최대 24시간(1440분)까지 설정 가능합니다.';
    return null;
  }

  // ── Combine validators ────────────────────────────────────────────────────

  /// Runs multiple validators in sequence, returning the first error found.
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
