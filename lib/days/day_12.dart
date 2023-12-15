import 'package:aoc/day.dart';
import 'package:aoc/days/util.dart';
import 'package:collection/collection.dart';
import 'package:memoized/memoized.dart';
import 'package:meta/meta.dart';

class DeepEqualList<T> extends DelegatingList<T> {
  const DeepEqualList(super.list);

  @override
  bool operator ==(Object other) {
    if (other is DeepEqualList<T>) {
      return const ListEquality().equals(this, other);
    }
    return false;
  }

  @override
  int get hashCode => const ListEquality().hash(this);
}

@immutable
class NonogramRow {
  static final int Function(String cells, DeepEqualList<int> hints)
      _countSolutions = Memoized2(
    _internalCountSolutions,
    capacity: 1000000,
  );

  final List<int> hints;
  final String cells;

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
      cells: row,
    );
  }

  static int _internalCountSolutions(String cells, DeepEqualList<int> hints) {
    if (hints.isEmpty) {
      return cells.chars.any((c) => c == '#') ? 0 : 1;
    }

    if (cells.isEmpty) {
      return 0;
    }

    if (cells.length < hints.reduce((a, b) => a + b) + hints.length - 1) {
      return 0;
    }

    final firstCell = cells.chars.first;
    switch (firstCell) {
      case '.':
        return _countSolutions(cells.substring(1), hints);
      case '?':
        final a = _countSolutions('#${cells.substring(1)}', hints);
        final b = _countSolutions('.${cells.substring(1)}', hints);
        return a + b;
      case '#':
        final hint = hints.first;
        for (var i = 0; i < hint; i += 1) {
          if (cells[i] == '.') {
            return 0;
          }
        }

        if (hint < cells.length) {
          if (cells[hint] == '#') {
            return 0;
          }
          return _countSolutions(
              cells.substring(hint + 1), DeepEqualList(hints.slice(1)));
        } else if (hint == cells.length) {
          return _countSolutions('', DeepEqualList(hints.slice(1)));
        } else {
          return 0;
        }
      default:
        throw StateError('Invalid char: $firstCell');
    }
  }

  int countSolutions() {
    return _countSolutions(cells, DeepEqualList(hints));
  }

  @override
  String toString() {
    return '$cells $hints';
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
