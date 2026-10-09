library;

const List<String> _months = [
  'yan',
  'fev',
  'mar',
  'apr',
  'may',
  'iyn',
  'iyl',
  'avg',
  'sen',
  'okt',
  'noy',
  'dek',
];

String _hm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String orderDateLabel(DateTime? date, {DateTime? now}) {
  if (date == null) return '';
  final local = date.toLocal();
  final today = now?.toLocal() ?? DateTime.now();

  final d = DateTime(local.year, local.month, local.day);
  final t = DateTime(today.year, today.month, today.day);
  final diffDays = t.difference(d).inDays;

  if (diffDays == 0) return 'Bugun, ${_hm(local)}';
  if (diffDays == 1) return 'Kecha, ${_hm(local)}';

  final month = _months[local.month - 1];
  if (local.year == today.year) {
    return '${local.day}-$month, ${_hm(local)}';
  }
  return '${local.day}-$month ${local.year}';
}

String orderDateShort(DateTime? date, {DateTime? now}) {
  if (date == null) return '';
  final local = date.toLocal();
  final today = now?.toLocal() ?? DateTime.now();

  final d = DateTime(local.year, local.month, local.day);
  final t = DateTime(today.year, today.month, today.day);
  final diffDays = t.difference(d).inDays;

  if (diffDays == 0) return 'Bugun';
  if (diffDays == 1) return 'Kecha';

  final month = _months[local.month - 1];
  return local.year == today.year
      ? '${local.day}-$month'
      : '${local.day}-$month ${local.year}';
}

String orderTimeAgo(DateTime? date, {DateTime? now}) {
  if (date == null) return '';
  final local = date.toLocal();
  final today = now?.toLocal() ?? DateTime.now();
  final diff = today.difference(local);

  if (diff.isNegative) return orderDateLabel(date, now: now);
  if (diff.inMinutes < 1) return 'Hozirgina';
  if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
  if (diff.inHours < 24) return '${diff.inHours} soat oldin';
  return orderDateLabel(date, now: now);
}
