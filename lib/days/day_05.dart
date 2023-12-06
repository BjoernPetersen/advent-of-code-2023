import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

@immutable
class NumMapping {
  final int from;
  final int to;
  final int length;

  const NumMapping(
      {required this.from, required this.to, required this.length});

  factory NumMapping.fromString(String line) {
    final [to, from, length] = line.split(' ');
    return NumMapping(
      from: int.parse(from),
      to: int.parse(to),
      length: int.parse(length),
    );
  }

  int operator [](int from) {
    final difference = from - this.from;
    if (difference >= 0 && difference < length) {
      return to + difference;
    } else {
      return -1;
    }
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

class Almanac {
  final List<int> seeds;
  final List<NumMap> maps;

  const Almanac(this.seeds, this.maps);

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

const day = Day(
  PartOne(),
);
