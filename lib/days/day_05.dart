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

  NumMap sort() {
    return NumMap(name, mappings.toList(growable: false)..sort());
  }

  NumMap invert() {
    return NumMap(
      name,
      mappings.map((e) => e.invert()).toList(growable: false),
    );
  }

  NumMap then(NumMap next) {
    // TODO: fix this mess
    final sortedSelf = sort();
    final sortedNext = next.sort();
    final nexts = sortedNext.mappings.iterator;
    nexts.moveNext();

    final combined = <NumMapping>[];
    for (final source in sortedSelf.mappings) {
      final (minTo, maxTo) = source.toBounds;
      var next = nexts.current;
      var (minFrom, maxFrom) = next.fromBounds;

      while (minTo > maxFrom) {
        if (!nexts.moveNext()) {
          break;
        }

        next = nexts.current;
        (minFrom, maxFrom) = next.fromBounds;
      }

      if (minTo < minFrom) {
        // Our range startes before theirs
        if (maxTo < minFrom) {
          // We're entirely before the other range, so just move on.
          continue;
        } else if (maxTo >= minFrom && maxTo < maxFrom) {
          // Partial overlap.
          final length = maxTo - minFrom + 1;
          final from = next.from - source.effect;
          final to = next.to;
          combined.add(NumMapping(from: from, to: to, length: length));
        } else if (maxTo >= maxFrom) {
          // Source range fully includes target range, so we just copy it
          final length = next.length;
          final from = next.from - source.effect;
          final to = next.to;
          combined.add(NumMapping(from: from, to: to, length: length));

          // TODO: should move iterator here
        }
      } else if (minTo == minFrom) {}
    }

    return NumMap(name, combined);
  }

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

  Almanac invert() {
    return Almanac(
      seeds,
      maps.reversed.map((e) => e.invert()).toList(growable: false),
    );
  }

  Almanac flatten() {
    return Almanac(seeds, [maps.reduce((a, b) => a.then(b))]);
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

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final originalAlmanac = await Almanac.fromInput(input);
    final almanac = originalAlmanac.flatten();
    return almanac.seedsPartTwo
        .map(almanac.findLocationNumber)
        .reduce((value, element) => value > element ? element : value);
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
