import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

enum Color {
  blue,
  green,
  red;
}

@immutable
final class Set {
  static const Set zero = Set._([0, 0, 0]);

  final List<int> _values;

  int get total => _values.reduce((value, element) => value + element);

  int get power => _values.reduce((value, element) => value * element);

  int getCount(Color color) {
    return _values[color.index];
  }

  const Set._(this._values);

  factory Set.fromRecord(String setRecord) {
    final values = List.filled(Color.values.length, 0);

    for (final colorRecord in setRecord.split(', ')) {
      final [numString, colorName] = colorRecord.split(' ');
      final num = int.parse(numString);
      for (final color in Color.values) {
        if (color.name == colorName) {
          values[color.index] = num;
        }
      }
    }

    return Set._(values);
  }

  factory Set.fixed({required int blue, required int green, required int red}) {
    return Set._([blue, green, red]);
  }

  bool operator <=(Set other) {
    if (total > other.total) {
      return false;
    }

    for (final color in Color.values) {
      if (getCount(color) > other.getCount(color)) {
        return false;
      }
    }

    return true;
  }

  Set minimum(Set other) {
    final result = List.of(_values, growable: false);
    for (final color in Color.values) {
      final otherCount = other.getCount(color);
      if (otherCount > getCount(color)) {
        result[color.index] = otherCount;
      }
    }
    return Set._(result);
  }
}

@immutable
final class GameRecord {
  final int id;
  final List<Set> sets;

  GameRecord(this.id, this.sets);

  factory GameRecord.fromLine(String line) {
    final sets = <Set>[];
    final [gameName, setRecords] = line.split(': ');
    final gameId = int.parse(gameName.split(' ')[1]);
    for (final setRecord in setRecords.split('; ')) {
      sets.add(Set.fromRecord(setRecord));
    }
    return GameRecord(gameId, sets);
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final comparisonSet = Set.fixed(blue: 14, green: 13, red: 12);
    return await input
        .map(GameRecord.fromLine)
        .where((game) => game.sets.every((set) => set <= comparisonSet))
        .fold(0, (previous, element) => previous + element.id);
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    return await input
        .map(GameRecord.fromLine)
        .map((game) => game.sets.fold(
              Set.zero,
              (previous, element) => previous.minimum(element),
            ))
        .map((set) => set.power)
        .reduce((previous, element) => previous + element);
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
