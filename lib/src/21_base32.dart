// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:math';

import 'package:meta/meta.dart';
import 'package:xrandom/src/00_jsnumbers.dart';

import '00_errors.dart';
import '00_ints.dart';

@pragma('vm:prefer-inline')
double doornikNextFloat(int u32) {
  // https://www.doornik.com/research/randomdouble.pdf

  const M_RAN_INVM32 = 2.32830643653869628906e-010;
  return u32.uint32_to_int32() * M_RAN_INVM32 + 0.5;
}

/// An abstract base class for all generators in the library,
/// based on algorithms that generate either 32-bit or 64-bit integers.
///
/// This class provides conversion options between the returned value types,
/// but does not specify how exactly we get the original random integer.
///
/// If the output of the algorithm is 32-bit, then the generator inherits
/// directly from [RandomBase32]. If the output of the algorithm is 64-bit,
/// then the generator inherits from [RandomBase64], that overloads some of the
/// [RandomBase32] methods.
///
/// Only generators inherited from [RandomBase32], but not from [RandomBase64],
/// can work in JavaScript. However, the mere fact of inheriting from [RandomBase32]
/// is not synonymous with JavaScript compatibility. For example, the [Mulberry32]
/// class is based on an algorithm that generates 32-bit integers and inherits from
/// [RandomBase32]. But the algorithm requires 64-bit support, which is not
/// available in JavaScript.
abstract class RandomBase32 implements Random {
  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 0 to 0xFFFFFFFF, both inclusive.
  ///
  /// For individual algorithms, these boundaries may actually differ. For example,
  /// algorithms in the Xorshift family never return zero.
  ///
  /// It is the raw output of the generator.
  int nextRaw32();

  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 0 to 2^64-1, both inclusive.
  ///
  /// This method only works on VM. If you try to execute it in JS, an
  /// [Unsupported64Error] will be thrown.
  ///
  /// The raw numbers generated by the algorithm are 32-bit. This method
  /// combines two results of [nextRaw32], placing the first number in the upper bits
  /// of the 64-bit, and the second in the lower bits.
  @pragma('vm:prefer-inline')
  int nextRaw64() {
    if (!INT64_SUPPORTED) {
      throw Unsupported64Error();
    }
    return (this.nextRaw32() << 32) | this.nextRaw32();
  }

  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 0, inclusive, to 2^63, exclusive.
  @pragma('vm:prefer-inline')
  int nextRaw53() {
    return INT64_SUPPORTED
        ? nextRaw64().unsignedRightShift(11)
        : combineUpper53bitsJS(nextRaw32(), nextRaw32());
  }

  static final int _POW2_32 = 4294967296; // it's (1 << 32). For JS it's safer to set a constant

  /// Generates a non-negative random integer uniformly distributed in
  /// the range from 0, inclusive, to [max], exclusive.
  @override
  int nextInt(int max) {
    // almost the same as https://bit.ly/35OH1Vh by Dart authors, BSD

    if (max <= 0 || max > _POW2_32) {
      throw RangeError.range(max, 1, _POW2_32, 'max', 'Must be positive and <= 2^32');
    }
    
    if ((max & -max) == max) {
      // Fast case for powers of two.
      return nextRaw32() & (max - 1);
    }

    int rnd32;
    int result;
    do {
      rnd32 = nextRaw32();
      result = rnd32 % max;
    } while ((rnd32 - result + max) > _POW2_32);
    return result;
  }

  /// Generates a random floating point value uniformly distributed
  /// in the range from 0.0, inclusive, to 1.0, exclusive.
  ///
  /// This method works faster than [nextDouble]. It sacrifices accuracy for speed.
  /// The result is mapped from a single 32-bit integer to [double].
  /// Therefore, the variability is limited by the number of possible values of
  /// such integer: 2^32 (= 4 294 967 296).
  ///
  /// This method uses the conversion suggested by J. Doornik in "Conversion of
  /// high-period random numbers to floating point" (2005).
  double nextFloat() {
    // https://www.doornik.com/research/randomdouble.pdf
    const M_RAN_INVM32 = 2.32830643653869628906e-010;
    return nextRaw32().uint32_to_int32() * M_RAN_INVM32 + 0.5;
  }

  /// Generates a random floating point value uniformly distributed
  /// in the range from 0.0, inclusive, to 1.0, exclusive.
  ///
  /// The results of this method exactly repeat the numbers usually generated
  /// by algorithms in C99 or C++. For example, this allows you to accurately
  /// reproduce the values of the generator used in the Chrome browser.
  ///
  /// In C99, the type conversion is described by S. Vigna as follows:
  ///
  /// ```
  /// static inline double to_double(uint64_t x) {
  ///   const union { uint64_t i; double d; } u = {
  ///     .i = UINT64_C(0x3FF) << 52 | x >> 12
  ///   };
  ///   return u.d - 1.0;
  /// }
  /// ```
  @override
  double nextDouble() {
    return nextRaw32() * 2.3283064365386963e-10 + (nextRaw32() >> 12) * 2.220446049250313e-16;
  }

  @override
  bool nextBool() {
    // we're returning bits from higher to lower: like uint32s from int64s
    if (boolCache_prevShift == 0) {
      boolCache = nextRaw32();
      boolCache_prevShift = 31;
      return boolCache & 0x80000000 != 0;
    } else {
      assert(boolCache_prevShift > 0);
      boolCache_prevShift--;
      final result = (boolCache & (1 << boolCache_prevShift)) != 0;
      return result;
    }
  }

  @protected
  int boolCache = 0;

  @protected
  int boolCache_prevShift = 0;
}
