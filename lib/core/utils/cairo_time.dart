class CairoTime {
  CairoTime._();

  static const Duration _cairoOffset = Duration(hours: 3);

  static DateTime now() => DateTime.now().toUtc().add(_cairoOffset);

  static DateTime? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final value = raw.trim();
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return null;
    }

    return _hasExplicitTimezone(value)
        ? parsed.toUtc().add(_cairoOffset)
        : parsed;
  }

  static DateTime normalize(DateTime value) {
    return value.isUtc ? value.toUtc().add(_cairoOffset) : value;
  }

  static bool _hasExplicitTimezone(String value) {
    return value.endsWith('Z') ||
        RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(value);
  }
}
