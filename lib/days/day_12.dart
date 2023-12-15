import 'package:aoc/day.dart';
import 'package:aoc/days/util.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

Iterable<List<bool>> getPermutations(List<bool?> cells) sync* {
  final unknownIndex = cells.indexOf(null);
  if (unknownIndex > -1) {
    cells[unknownIndex] = true;
    yield* getPermutations(cells);
    cells[unknownIndex] = false;
    yield* getPermutations(cells);
    cells[unknownIndex] = null;
  } else {
    yield cells.cast<bool>();
  }
}

@immutable
class NonogramRow {
  final List<int> hints;
  final List<bool?> cells;

  const NonogramRow({required this.hints, required this.cells});

  factory NonogramRow.fromLine(String line, {int multiplier = 1}) {
    var [row, hints] = line.split(' ');

    if (multiplier > 1) {
      final newRow = ('$row?' * multiplier);
      row = newRow.substring(0, newRow.length - 1);
      final newHints = '$hints,' * multiplier;
      hints = newHints.substring(0, newHints.length - 1);
    }

    return NonogramRow(
      hints: hints.split(',').map(int.parse).toList(growable: false),
      cells: row.chars
          .map((c) => switch (c) {
                '#' => true,
                '.' => false,
                '?' => null,
                _ => throw ArgumentError('Invalid character: $c'),
              })
          .toList(growable: false),
    );
  }

  bool isSolution(List<bool> row) {
    final groups = <int>[];
    var current = 0;
    for (final cell in row) {
      if (cell) {
        current += 1;
      } else if (current > 0) {
        groups.add(current);
        current = 0;
      }
    }
    if (current > 0) {
      groups.add(current);
    }

    return ListEquality().equals(groups, hints);
  }

  int countSolutions() {
    return getPermutations(cells.toList(growable: false)).where((row) => isSolution(row)).length;
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) {
    return input
        .map(NonogramRow.fromLine)
        .map((n) => n.countSolutions())
        .reduce((a, b) => a + b);
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) {
    return input
        .map((line) => NonogramRow.fromLine(line, multiplier: 5))
        .map((n) => n.countSolutions())
        .reduce((a, b) => a + b);
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
