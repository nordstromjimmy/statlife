// date helper
String dateKey(DateTime dt) {
  final d = DateTime(dt.year, dt.month, dt.day);
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}$mm$dd'; //yyyyMMdd style
}

DateTime dateFromKey(String key) {
  final y = int.parse(key.substring(0, 4));
  final m = int.parse(key.substring(4, 6));
  final d = int.parse(key.substring(6, 8));
  return DateTime(y, m, d);
}

DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
