// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT


import '00_ints.dart';
import '21_base32.dart';



abstract class RandomBase64 extends RandomBase32 {
  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 1 to 2^64-1, both inclusive.
  ///
  /// It is the raw output of the generator.
  @override
  int nextRaw64();

  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 0 to 0xFFFFFFFF, both inclusive.
  ///
  /// The raw numbers generated by the algorithm are 64-bit. This method returns
  /// the highest 32 bits, and then the lowest 32 bits of the generated numbers.
  ///
  /// Note that unlike the [RandomBase32.nextRaw32], this overridden method
  /// can return 0.
  @override
  int nextRaw32() {
    // we assume that the random generator never returns 0,
    // so 0 means "not initialized".
    if (_split64 == 0) {
      _split64 = this.nextRaw64();

      // returning UPPER four bytes
      const unsignedRightShift = 32;
      return (_split64 >> unsignedRightShift) & ~(-1 << (64 - unsignedRightShift)); // >>>

    } else {
      // we have a value: that means, we're already returned
      // the higher 4 bytes of it. Now we'll return the lower 4 bytes
      final result = _split64 & UINT32_MAX;
      _split64 = 0; // on the next call we'll need a new random here

      assert(result != 0);
      assert(result <= 0xFFFFFFFF);
      return result;
    }
  }

  int _split64 = 0;

  //
  // REMARKS to nextInt32:
  //
  // In 32-bit generators, to get an int64, we use te FIRST four bytes as
  // the UPPER, and the NEXT as the LOWER parts of int64. It's just because
  // most suggestions on the internet look like (rnd32()<<32)|rnd32().
  // That is, we have a conveyor like this:
  //
  // F1( FFFF, LLLL, FFFF, LLLL ) -> FFFFLLLL, FFFFLLLL
  //
  // In 64-bit generators, to split an int64 to two 32-bit integers, we want
  // the opposite, i.e.
  //
  // F2 ( FFFFLLLL, FFFFLLLL ) -> FFFF, LLLL, FFFF, LLLL
  //
  // So F1(F2(X))=X, F2(F1(Y))=Y.
  //
  // That's why we return highest bytes first, lowest bytes second
  //

  @override
  double nextDouble() {
    // the result of printf("%.60e", 0x1.0p-53):
    const double Z = 1.110223024625156540423631668090820312500000000000000000000000e-16;

    //_____(this.nextInt64()_>>>_11______________________)_*_0x1.0p-53
    return ((this.nextRaw64() >> 11) & ~(-1 << (64 - 11))) * Z;
  }

  //
  // REMARKS to nextDouble:
  //
  // we have a 64-bit integer to be converted to a float with only 53
  // significant bits.
  //
  // Vigna (https://prng.di.unimi.it/):
  //  64-bit unsigned integer x should be converted to a 64-bit double using
  //  the expression
  //    (x >> 11) * 0x1.0p-53
  //  In Java you can use almost the same expression for a (signed)
  //  64-bit integer:
  //    (x >>> 11) * 0x1.0p-53
  //

  @override
  bool nextBool() {
    // we're returning bits from higher to lower
    if (boolCache_prevShift == 0) {
      boolCache = nextRaw64();
      boolCache_prevShift = 63;
      return boolCache < 0; // for the signed integer negative = highest bit set
    } else {
      assert(boolCache_prevShift > 0);
      boolCache_prevShift--;
      final result = (boolCache & (1 << boolCache_prevShift)) != 0;
      return result;
    }
  }

  /// Generates a non-negative random floating point value uniformly distributed
  /// in the range from 0.0, inclusive, to 1.0, exclusive.
  ///
  /// For the Dart this method is slower than [nextDouble] and has no
  /// advantages over [nextDouble].
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
  double nextDoubleBitcast() {
    // this is the same as RandomBase32.nextDouble()
    return nextRaw32() * 2.3283064365386963e-10 + (nextRaw32() >> 12) * 2.220446049250313e-16;
  }
}
