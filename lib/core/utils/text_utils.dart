String slugify(String value) {
  final normalized = value.toLowerCase().trim();
  final cleaned = normalized.replaceAll(RegExp(r'[^a-z0-9\s-]'), '');
  final collapsed = cleaned.replaceAll(RegExp(r'[\s_-]+'), '-');
  return collapsed.replaceAll(RegExp(r'^-+|-+$'), '');
}

String capitalizeWords(String value) {
  return value
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

String initialsFrom(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'W';
  if (parts.length == 1) {
    final word = parts.first;
    return word.substring(0, word.length.clamp(1, 2)).toUpperCase();
  }
  return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
}

String formatMoney(num value, {String symbol = '৳'}) {
  final amount = value.toDouble();
  final hasDecimals = amount % 1 != 0;
  final formatted = hasDecimals
      ? amount.toStringAsFixed(2)
      : amount.toStringAsFixed(0);
  return '$symbol $formatted';
}

String formatShortDate(DateTime? date) {
  if (date == null) return '-';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatDateTime(DateTime? date) {
  if (date == null) return '-';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/${date.year}, $hour:$minute';
}
