import 'package:aoc/day.dart';
import 'package:aoc/days/util.dart';
import 'package:meta/meta.dart';

@immutable
class Universe {
  final List<List<int>> _quadrants;
  final List<Vector> galaxies;

  int get width => _quadrants[0].length;

  int get height => _quadrants.length;

  const Universe._(this._quadrants, this.galaxies);

  static Future<Universe> fromInput(Stream<String> input) async {
    final result = <List<int>>[];
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
      result.add(row);
      if (rowIsEmpty) {
        result.add(row);
      }
    }

    final galaxies = <Vector>[];
    final expanded = List.generate(
      result.length,
      (y) {
        final row = result[y];
        final newRow = <int>[];
        for(final (index, id) in row.indexed) {
          if (id != 0) {
            final location = Vector(x:newRow.length, y: y);
            galaxies.add(location);
          }

          if (columnCounts[index] == 0) {
            newRow.add(0);
            newRow.add(0);
          } else {
            newRow.add(id);
          }
        }
        return row.indexed.expand((e) {
          final (index, value) = e;
          if (columnCounts[index] == 0) {
            return [value, value];
          } else {
            return [value];
          }
        }).toList(growable: false);
      },
      growable: false,
    );
    return Universe._(expanded, galaxies);
  }

  int operator [](Vector position) {
    return _quadrants[position.y][position.x];
  }

  String toHumanReadable() {
    return _quadrants
        .map((row) => row.map((id) => id == 0 ? '.' : id).join())
        .join('\n');
  }

  @override
  String toString() {
    return 'Universe [${width}x$height][${galaxies.length}]';
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final universe = await Universe.fromInput(input);
    // Whoops, didn't need that two-dimensional array after all.
    final galaxies = universe.galaxies;
    var sum = 0;
    for(final (index, galaxy) in galaxies.indexed) {
      for(var otherIndex = index + 1; otherIndex < galaxies.length; otherIndex +=1) {
        final otherGalaxy = galaxies[otherIndex];
        sum += (otherGalaxy - galaxy).manhattanNorm();
      }
    }
    return sum;
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final universe = await Universe.fromInput(input);
    // Whoops, didn't need that two-dimensional array after all.
    final galaxies = universe.galaxies;
    var sum = 0;
    for(final (index, galaxy) in galaxies.indexed) {
      for(var otherIndex = index + 1; otherIndex < galaxies.length; otherIndex +=1) {
        final otherGalaxy = galaxies[otherIndex];
        sum += (otherGalaxy - galaxy).manhattanNorm();
      }
    }
    return sum;
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
