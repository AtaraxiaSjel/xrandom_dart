// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

@TestOn('vm')

import "package:test/test.dart";
import 'package:xrandom/src/00_ints.dart';
import 'package:xrandom/src/xoshiro256pp.dart';



// xorshift128 (seed 1081037251 1975530394 2959134556 1579461830)
// 'xorshift128 (seed 5 23 42 777)'
// 'xorshift128 (seed 1 2 3 4)'

import 'helper.dart';

void main() {

  // print(BigInt.parse('0xf7d3b43bed078fa3').toInt());
  // print(0xf7d3b43bed078fa3);
  // return;

  //print(unsignedRightShiftCode("x","32-k"));
  //return;

  // xoshiro128++ (seed 00000001 00000002 00000003 00000004)
  // xoshiro128++ (seed 406f51c3 75c0339a b060cf5c 5e24acc6)
  // xoshiro128++ (seed 00000005 00000017 0000002a 00000309)

  // test("reference data", () {
  //   expect(
  //       referenceSignature("xoshiro128++ (seed 00000001 00000002 00000003 00000004)"),
  //       ['00002025', '0000383e', '0000282c', '2ee0065b']);
  //   // expect(
  //   //     referenceSignature("xorshift128 (seed 5 23 42 777)"),
  //   //     ['00185347', '0019023e', '0019ba92', '91050530']);
  //   // expect(
  //   //     referenceSignature("xorshift128 (seed 1081037251 1975530394 2959134556 1579461830)"),
  //   //     ['3b568794', '8dfab58d', 'f9d21b4b', '4b5d88e5']);
  //
  // });

  // test("seed A", () {
  //   final random = Xoshiro128pp(1, 2, 3, 4);
  //   compareWithReference32(random, "xoshiro128++ (seed 00000001 00000002 00000003 00000004)");
  // });
  //
  // test("seed B", () {
  //   final random = Xoshiro128pp(5, 23, 42, 777);
  //   compareWithReference32(random, "xoshiro128++ (seed 00000005 00000017 0000002a 00000309)");
  // });
  // //
  // test("seed C", () {
  //   final random = Xoshiro128pp(1081037251, 1975530394, 2959134556, 1579461830);
  //   compareWithReference32(random, "xoshiro128++ (seed 406f51c3 75c0339a b060cf5c 5e24acc6)");
  // });




  testCommonRandom(()=>Xoshiro256pp());
  checkReferenceFiles(()=>Xoshiro256pp(1, 2, 3, 4), 'a');
  checkReferenceFiles(()=>Xoshiro256pp(5, 23, 42, 777), 'b');
  checkReferenceFiles(()=>Xoshiro256pp(
      // 0x621b97ff9b08ce44,
      // 0x92974ae633d5ee97,
      // 0x9c7e491e8f081368,
      // 0xf7d3b43bed078fa3

      int.parse('0x621b97ff9b08ce44'),
      int.parse('0x92974ae633d5ee97'),
      int.parse('0x9c7e491e8f081368'),
      int.parse('0xf7d3b43bed078fa3'),


      // BigInt.parse('0x621b97ff9b08ce44').toInt(),
      // BigInt.parse('0x92974ae633d5ee97').toInt(),
      // BigInt.parse('0x9c7e491e8f081368').toInt(),
      // BigInt.parse('0xf7d3b43bed078fa3').toInt()

  ), 'c');

  //
  // test("predefined next", () {
  //   final random = Xoshiro128.deterministic();
  //   expect(
  //       skipAndTake(()=>random.nextInt32().toHexUint32(), 5000, 3),
  //       ['682C4EE4', '208190FD', '455F4A85']
  //   );
  // });
  //
  // // test("predefined double", () {
  // //   final random = Xorshift128.deterministic();
  // //   expect(
  // //       skipAndTake(()=>random.nextDouble(), 5000, 3),
  // //       [0.8217153680630882, 0.16883535742482325, 0.2059260621445983]
  // //   );
  // // });
  //
  // test("create without args", ()  async {
  //   final random1 = Xoshiro128();
  //   await Future.delayed(Duration(milliseconds: 2));
  //   final random2 = Xorshift128();
  //
  //   expect(
  //       [random1.nextInt32(), random1.nextInt32()],
  //       isNot([random2.nextInt32(), random2.nextInt32()]));
  // });

}