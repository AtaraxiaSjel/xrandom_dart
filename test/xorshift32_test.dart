// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <ortemeo@gmail
// SPDX-License-Identifier: MIT

import "package:test/test.dart";
import 'package:xorhift/ints.dart';
import 'package:xorhift/xorshift32.dart';

import 'helper.dart';
import 'reference.dart';

void main() {

  test("reference data", () {
    expect(
        referenceSignature("xorshift32 (seed 1)"),
        ['00042021', '04080601', '9dcca8c5', '7c43326e']);
    expect(
        referenceSignature("xorshift32 (seed 42)"),
        ['00ad4528', 'a90a34ac', '1c67af03', '7478bd43']);
    expect(
        referenceSignature("xorshift32 (seed 314159265)"),
        ['b11ddc17', '59781258', '3d54c7e1', '8d87618b']);

  });

  test("seed 1", () {
    final random = Xorshift32Random(1);
    compareWithReference(random, "xorshift32 (seed 1)");
  });

  test("seed 42", () {
    final random = Xorshift32Random(42);
    compareWithReference(random, "xorshift32 (seed 42)");
  });

  test("seed 314159265", () {
    final random = Xorshift32Random(314159265);
    compareWithReference(random, "xorshift32 (seed 314159265)");
  });

  test("doubles", ()=>checkDoubles(Xorshift32Random(777)));
  test("bools", ()=>checkBools(Xorshift32Random(777)));
  test("ints", ()=>checkInts(Xorshift32Random(777)));

  test("predefined next", () {
    final random = Xorshift32Random.deterministic();
    expect(
        skipAndTake(()=>random.next().toHexUint32(), 5000, 3),
        ['62982C53', '855D849A', '8C1511DD']
    );
  });

  test("predefined double", () {
    final random = Xorshift32Random.deterministic();
    expect(
        skipAndTake(()=>random.nextDouble(), 5000, 3),
        [0.385134477723654, 0.5209582209403064, 0.5471964991994194]
    );
  });
}