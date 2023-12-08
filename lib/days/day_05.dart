import 'dart:isolate';
import 'dart:math';

import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

@immutable
class NumMapping implements Comparable<NumMapping> {
  final int from;
  final int to;
  final int length;

  const NumMapping({
    required this.from,
    required this.to,
    required this.length,
  });

  NumMapping invert() {
    return NumMapping(
      from: to,
      to: from,
      length: length,
    );
  }

  factory NumMapping.fromString(String line) {
    final [to, from, length] = line.split(' ');
    return NumMapping(
      from: int.parse(from),
      to: int.parse(to),
      length: int.parse(length),
    );
  }

  int get effect => to - from;

  int operator [](int from) {
    final difference = from - this.from;
    if (difference >= 0 && difference < length) {
      return to + difference;
    } else {
      return -1;
    }
  }

  (int, int) get fromBounds => (from, from + length - 1);

  (int, int) get toBounds => (to, to + length - 1);

  @override
  int compareTo(NumMapping other) {
    return from.compareTo(other.from);
  }
}

@immutable
class NumMap {
  final String name;
  final List<NumMapping> mappings;

  const NumMap(this.name, this.mappings);

  int operator [](int from) {
    // TODO: could order mappings to break early
    for (final mapping in mappings) {
      final value = mapping[from];
      if (value > -1) {
        return value;
      }
    }
    return from;
  }
}

@immutable
class Almanac {
  final List<int> seeds;
  final List<NumMap> maps;

  const Almanac(this.seeds, this.maps);

  Iterable<int> get seedsPartTwo sync* {
    for (var i = 0; i < seeds.length; i += 2) {
      final from = seeds[i];
      final length = seeds[i + 1];
      for (var seed = from; seed < from + length; seed += 1) {
        yield seed;
      }
    }
  }

  static Future<Almanac> fromInput(Stream<String> lines) async {
    final seeds = <int>[];
    final maps = <NumMap>[];
    var currentName = '';
    var currentMappings = <NumMapping>[];
    await lines.forEach((line) {
      if (seeds.isEmpty) {
        line.split(': ')[1].split(' ').map(int.parse).forEach(seeds.add);
        return;
      }

      if (line.isEmpty) {
        if (currentMappings.isNotEmpty) {
          maps.add(NumMap(currentName, currentMappings));
          currentMappings = [];
          currentName = '';
        }
        return;
      }

      if (currentMappings.isEmpty && currentName.isEmpty) {
        currentName = line.substring(0, line.length - 5);
        return;
      }

      currentMappings.add(NumMapping.fromString(line));
    });

    maps.add(NumMap(currentName, currentMappings));
    return Almanac(seeds, maps);
  }

  int findLocationNumber(int seed) {
    var currentNum = seed;
    for (final map in maps) {
      currentNum = map[currentNum];
    }
    return currentNum;
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final almanac = await Almanac.fromInput(input);
    return almanac.seeds
        .map(almanac.findLocationNumber)
        .reduce((value, element) => value > element ? element : value);
  }
}

const enableMultithreading = false;

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final almanac = await Almanac.fromInput(input);

    if (enableMultithreading) {
      final seeds = almanac.seeds;
      final calculators = List.generate(
        seeds.length ~/ 2,
        (index) => Calculator(
          almanac: almanac,
          from: seeds[index * 2],
          length: seeds[index * 2 + 1],
        ),
        growable: false,
      );

      return Stream.fromFutures(calculators.map((c) => c.calculate()))
          .reduce(min);
    } else {
      return almanac.seedsPartTwo.map(almanac.findLocationNumber).reduce(min);
    }
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);

@immutable
class Calculator {
  final Almanac almanac;
  final int from;
  final int length;

  const Calculator(
      {required this.almanac, required this.from, required this.length});

  Future<int> calculate() {
    final from = this.from;
    final length = this.length;
    return Isolate.run(() {
      var minLocation = almanac.findLocationNumber(from);
      for (var seed = from; seed < from + length; seed += 1) {
        minLocation = min(minLocation, almanac.findLocationNumber(seed));
      }
      return minLocation;
    });
  }
}
