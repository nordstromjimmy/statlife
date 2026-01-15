import 'dart:math';

int requriedXpForLevel(int level) {
  // XP needed to go from (level) -> (level + 1)
  // Level 1 requries 100, Level 2 requires 150, Level 3 requires 225 etc..
  final base = 100.0;
  final multiplier = pow(1.5, level - 1);
  return (base * multiplier).round();
}

({int level, int xpIntoLevel, int xpForNext}) computeLevelFromTotalXp(
  int totalXp,
) {
  var level = 1;
  var remaining = totalXp;

  while (true) {
    final need = requriedXpForLevel(level);
    if (remaining >= need) {
      remaining -= need;
      level += 1;
      continue;
    }
    return (level: level, xpIntoLevel: remaining, xpForNext: need);
  }
}
