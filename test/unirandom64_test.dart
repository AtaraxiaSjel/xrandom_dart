// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

@TestOn('vm')
import 'dart:io';

import "package:test/test.dart";
import 'package:xrandom/src/00_ints.dart';
import 'package:xrandom/src/xorshift32.dart';
import 'package:xrandom/src/xorshift64.dart';

import 'helper.dart';
import 'reference.dart';

// class MyObject {
//
// }

void main() {
  test("next32 returning parts of next64", () {
    final random1 = Xorshift64.deterministic();
    int a64 = random1.nextInt64();
    int b64 = random1.nextInt64();

    final random2 = Xorshift64.deterministic();
    expect(random2.nextInt32(), a64.lower32());
    expect(random2.nextInt32(), a64.higher32());
    expect(random2.nextInt32(), b64.lower32());
    expect(random2.nextInt32(), b64.higher32());
  });

  test("nextBool on 64-bit generator: must return all bits", () {
    final randomA = Xorshift64.deterministic();
    final randomB = Xorshift64.deterministic();

    for (var experiment = 0; experiment < 100; ++experiment) {
      var intA = randomA.nextInt64();
      for (var bit = 0; bit < 64; ++bit) {
        expect(
            randomB.nextBool(),
            (intA & (1 << bit)) != 0,
            reason: "Experiment $experiment, bit $bit");
      }
    }
  });

  test("nextBool on 32-bit generator: must return all bits", () {
    final randomA = Xorshift32.deterministic();
    final randomB = Xorshift32.deterministic();

    for (var experiment = 0; experiment < 100; ++experiment) {
      var intA = randomA.nextInt32();
      for (var bit = 0; bit < 32; ++bit) {
        expect(
            randomB.nextBool(),
            (intA & (1 << bit)) != 0,
            reason: "Experiment $experiment, bit $bit");
      }
    }
  });

}
