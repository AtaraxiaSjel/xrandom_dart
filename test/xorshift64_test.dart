// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <ortemeo@gmail
// SPDX-License-Identifier: MIT

import "package:test/test.dart";
import 'package:xorhift/ints.dart';
import 'package:xorhift/xorshift64.dart';

// xorshift128 (seed 1081037251 1975530394 2959134556 1579461830)
// 'xorshift128 (seed 5 23 42 777)'
// xorshift128 (seed 1 2 3 4)'

// 'xorshift128plus (seed 1 2)'
// 'xorshift128plus (seed 42 777)'
// 'xorshift128plus (seed 1081037251 1975530394)'

import 'helper.dart';
import 'reference.dart';

void main() {

  test("reference data", () {
    expect(
        referenceSignature("xorshift64 (seed 1)"),
        ['0000000040822041', '100041060c011441', '9b1e842f6e862629', '1a79f717c30cd499']);
    expect(
        referenceSignature("xorshift64 (seed 42)"),
        ['0000000a95514aaa', 'a00aaafdf80202bf', '8b13399cd1d1497a', '19534e6bc7e4c934']);
    expect(
        referenceSignature("xorshift64 (seed 3141592653589793238)"),
        ['366b2d97e95498c5', '9546626d41d0a0b4', 'e23e2b18a287acf5', 'd81ada3db94a4ee1']);

  });

  test("seed 1", () {
    final random = Xorshift64Random(1);
    compareWithReference(random, "xorshift64 (seed 1)");
  });

  test("seed 42", () {
    final random = Xorshift64Random(42);
    compareWithReference(random, "xorshift64 (seed 42)");
  });

  test("seed 3141592653589793238", () {
    final random = Xorshift64Random(3141592653589793238);
    compareWithReference(random, "xorshift64 (seed 3141592653589793238)");
  });

  test("doubles", ()=>checkDoubles(Xorshift64Random(777)));
  test("bools", ()=>checkBools(Xorshift64Random(777)));
  test("ints", ()=>checkInts(Xorshift64Random(777)));

  test("predefined next", () {
    final random = Xorshift64Random.deterministic();
    expect(
        skipAndTake(()=>random.next().toHexUint64(), 5000, 3),
        ['A78D8BFA5E7260CA', '5DB7D12B9759F68B', 'ABD3D730279787A6']
    );
  });

  test("predefined double", () {
    final random = Xorshift64Random.deterministic();
    expect(
        skipAndTake(()=>random.nextDouble(), 5000, 3),
        [0.3090071651939921, 0.7321721518371331, 0.3424023614053875]
    );
  });
}