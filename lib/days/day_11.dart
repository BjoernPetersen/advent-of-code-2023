import 'package:aoc/day.dart';
import 'package:aoc/days/util.dart';
import 'package:meta/meta.dart';

@immutable
class Universe {
  final List<Vector> galaxies;

  const Universe._(this.galaxies);

  static Future<Universe> fromInput(Stream<String> input,
      {required int expansionFactor}) async {
    final result = <List<int>>[];
    final emptyRows = <int>[];
    late final List<int> columnCounts;

    int idCounter = 1;

    await for (final line in input) {
      if (result.isEmpty) {
        columnCounts = List.filled(line.length, 0);
      }

      final row = <int>[];
      bool rowIsEmpty = true;
      for (final (index, char) in line.chars.indexed) {
        if (char == '#') {
          rowIsEmpty = false;
          columnCounts[index] += 1;
          row.add(idCounter++);
        } else {
          row.add(0);
        }
      }

      if (rowIsEmpty) {
        emptyRows.add(result.length);
      }

      result.add(row);
    }

    final galaxies = <Vector>[];
    var emptyRowsAdded = 0;
    for (var y = 0; y < result.length; y += 1) {
      if (emptyRows.contains(y)) {
        emptyRowsAdded += expansionFactor - 1;
        continue;
      }

      final row = result[y];
      final newY = y + emptyRowsAdded - 1;

      var emptyColumnsAdded = 0;
      for (var x = 0; x < row.length; x += 1) {
        if (columnCounts[x] == 0) {
          emptyColumnsAdded += expansionFactor - 1;
          continue;
        }

        if (row[x] != 0) {
          final newX = x + emptyColumnsAdded;
          final location = Vector(x: newX, y: newY);
          galaxies.add(location);
        }
      }
    }

    return Universe._(galaxies);
  }

  int get sumOfGalaxyPairDistances {
    var sum = 0;
    for (final (index, galaxy) in galaxies.indexed) {
      for (var otherIndex = index + 1;
          otherIndex < galaxies.length;
          otherIndex += 1) {
        final otherGalaxy = galaxies[otherIndex];
        sum += (otherGalaxy - galaxy).manhattanNorm();
      }
    }
    return sum;
  }

  @override
  String toString() {
    return 'Universe [${galaxies.length}]';
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final universe = await Universe.fromInput(input, expansionFactor: 2);
    return universe.sumOfGalaxyPairDistances;
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final universe = await Universe.fromInput(input, expansionFactor: 1000000);
    return universe.sumOfGalaxyPairDistances;
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
