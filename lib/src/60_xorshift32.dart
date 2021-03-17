// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:xrandom/src/20_random_base.dart';

/// Random number generator based on **xorshift32** algorithm by G. Marsaglia (2003).
/// The reference implementation in C can be found in
/// <https://www.jstatsoft.org/article/view/v008i14>.
class Xorshift32 extends RandomBase32 {
  Xorshift32([int? seed32]) {
    if (seed32 != null) {
      RangeError.checkValueInInterval(seed32, 1, 0xFFFFFFFF);
      _state = seed32;
    } else {
      _state = (DateTime.now().millisecondsSinceEpoch ^ hashCode) & 0xFFFFFFFF;
    }
  }
  late int _state;

  static const defaultSeed = 0xd9e2fcc8;

  static Xorshift32 expected() => Xorshift32(defaultSeed);

  @override
  int nextInt32() {
    // algorithm from p.4 of "Xorshift RNGs"
    // by George Marsaglia, 2003
    // https://www.jstatsoft.org/article/view/v008i14
    //
    // rewritten for Dart from snippet
    // found at https://en.wikipedia.org/wiki/Xorshift

    var x = _state;

    x ^= (x << 13);
    x &= 0xFFFFFFFF; // added
    x ^= (x >> 17);
    x ^= (x << 5);
    x &= 0xFFFFFFFF; // added

    return _state = x;
  }
}