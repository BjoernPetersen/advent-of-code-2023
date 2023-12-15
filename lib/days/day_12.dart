import 'package:aoc/day.dart';
import 'package:aoc/days/util.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

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

  static int _countSolutions(List<bool?> cells, List<int> hints) {
    print('$cells $hints');
    if (hints.isEmpty) {
      return cells.any((c) => c == true) ? 0 : 1;
    }

    if (cells.isEmpty) {
      return 0;
    }

    if (cells.length < hints.reduce((a, b) => a + b) + hints.length - 1) {
      return 0;
    }

    final firstCell = cells.first;
    switch (firstCell) {
      case false:
        return _countSolutions(cells.slice(1), hints);
      case null:
        cells[0] = true;
        final a = _countSolutions(cells, hints);
        cells[0] = false;
        final b = _countSolutions(cells, hints);
        cells[0] = null;
        return a + b;
      case true:
        final hint = hints.first;
        for (var i = 0; i < hint; i += 1) {
          if (cells[i] == false) {
            return 0;
          }
        }

        if (hint < cells.length) {
          if (cells[hint] == true) {
            return 0;
          }
          return _countSolutions(cells.slice(hint + 1), hints.slice(1));
        } else if (hint == cells.length) {
          return _countSolutions([], hints.slice(1));
        } else {
          return 0;
        }
    }
  }

  int countSolutions() {
    print('${DateTime.now()} Starting new row: $this');
    return _countSolutions(cells.toList(growable: false), hints);
  }

  @override
  String toString() {
    final cellString = cells.map((c) {
      switch (c) {
        case true:
          return '#';
        case false:
          return '.';
        case null:
          return '?';
      }
    }).join();
    return '$cellString $hints';
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
