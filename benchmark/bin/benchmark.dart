// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:xorshift/xorshift.dart';

import 'nullsafe_tabulate.dart';

enum DoWhat { nextDouble, nextInt, nextBool, next32, next64 }

int measureTime(Random r, DoWhat dbl) {
  print('Benchmarking ${r.runtimeType}');

  final sw = Stopwatch()..start();

  const N = 100000000;

  switch (dbl) {
    case DoWhat.nextDouble:
      for (var i = 0; i < N; ++i) r.nextDouble();
      break;
    case DoWhat.nextBool:
      for (var i = 0; i < N; ++i) r.nextBool();
      break;
    case DoWhat.nextInt:
      for (var i = 0; i < N; ++i) r.nextInt(100);
      break;
    case DoWhat.next32:
      if (r is UniRandom32) {
        for (var i = 0; i < N; ++i) r.next32();
      }
      break;
    case DoWhat.next64:
      if (r is UniRandom64) {
        for (var i = 0; i < N; ++i) r.next64();
      }
      break;
  }

  return sw.elapsed.inMilliseconds;
}

int mean(List<int> values) => (values.reduce((a, b) => a + b) / values.length).round();

class Bench implements Comparable {
  Bench(this.className, this.doWhat);

  final String className;
  final DoWhat doWhat;
  final results = <int>[];

  @override
  String toString() {
    return className + doWhat.toString();
  }

  @override
  int compareTo(other) => toString().compareTo(other.toString());
}

//List<T> shuffled(List<T> a) {
//a.s
//}

void main(List<String> arguments) {
  final results = <String, Map<DoWhat, List<int>>>{};

  // git stash && git pull origin master && dart pub get && ./run.sh

  final dowhatz = [
    DoWhat.nextBool,
    DoWhat.nextInt,
    DoWhat.nextDouble,
    DoWhat.next32,
    DoWhat.next64
  ];

  List<Random> listGenerators() => [
        Random(777),
        Xorshift32.deterministic(),
        Xorshift64.deterministic(),
        Xorshift128.deterministic(),
        Xorshift128Plus.deterministic(),
      ];

  for (var experiment = 0; experiment < 4; ++experiment) {
    for (final doingWhat in dowhatz) {
      for (var random in listGenerators()..shuffle()) {
        final time = measureTime(random, doingWhat);
        results
            .putIfAbsent(random.runtimeType.toString(), () => <DoWhat, List<int>>{})
            .putIfAbsent(doingWhat, () => <int>[])
            .add(time);
      }
    }
  }

  final rows = <List<String>>[];

  final header = ['Class'];
  for (final x in dowhatz) {
    final str = x.toString();
    header.add(str.substring(str.lastIndexOf('.') + 1));
  }

  rows.add(header);

  final otherRows = <List<String>>[];

  for (final random in listGenerators()) {
    final row = <String>[];
    otherRows.add(row);

    final type = random.runtimeType.toString();
    row.add(type == '_Random' ? 'Random (dart:math)' : type);

    for (final doWhat in dowhatz) {
      final times = results[type]![doWhat]!;
      final avg = mean(times);
      row.add(avg == 0 ? '-' : avg.toString());
    }
  }

  rows.addAll(otherRows);

  print(tabulate(rows, rowAlign: [Align.left], headerAlign: [Align.left]));
}