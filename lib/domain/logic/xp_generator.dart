import 'dart:math';

class XpGenerator {
  static final _rng = Random();

  static int random({int min = 50, int max = 100}) {
    return min + _rng.nextInt(max - min + 1);
  }
}
