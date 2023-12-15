import 'package:aoc/day.dart';
import 'package:aoc/days/util.dart';
import 'package:meta/meta.dart';

@immutable
class NotePattern {
  final List<List<String>> _rows;

  const NotePattern._(this._rows);

  factory NotePattern.fromLines(Iterable<String> input) {
    final rows =
        input.map((line) => line.chars.toList(growable: false)).toList();
    return NotePattern._(rows);
  }

  int get width => _rows[0].length;

  int get height => _rows.length;

  Iterable<List<String>> get rows => _rows;

  Iterable<List<String>> get columns sync* {
    final width = this.width;
    for (var x = 0; x < width; x += 1) {
      yield _rows.map((row) => row[x]).toList(growable: false);
    }
  }

  bool _isReflection(List<String> line,
      {required int before, required int after}) {
    for (var index = before; index >= 0; index -= 1) {
      final counterIndex = after + (before - index);
      if (counterIndex == line.length) {
        return true;
      }

      final char = line[index];
      final counterChar = line[counterIndex];
      if (char != counterChar) {
        return false;
      }
    }

    return true;
  }

  Iterable<Reflection> _findReflections(
    List<String> line, {
    required bool isColumn,
  }) sync* {
    if (line.length.isEven) {
      throw ArgumentError.value(line, 'line', 'A line has an even length');
    }

    for (var left = 0; left < line.length - 1; left += 1) {
      final right = left + 1;
      if (_isReflection(line, before: left, after: right)) {
        yield Reflection(before: left, after: right, isVertical: !isColumn);
      }
    }
  }

  Reflection findReflection() {
    final rowReflections = rows
        .map((line) => _findReflections(line, isColumn: false))
        .reduce((a, b) => a.toSet().intersection(b.toSet()));
    if (rowReflections.isNotEmpty) {
      return rowReflections.single;
    }

    final columnReflections = columns
        .map((line) => _findReflections(line, isColumn: true))
        .reduce((a, b) => a.toSet().intersection(b.toSet()));
    if (columnReflections.isNotEmpty) {
      return columnReflections.single;
    }

    throw StateError('No reflection found');
  }

  @override
  String toString() {
    return _rows.map((row) => row.join()).join('\n');
  }
}

@immutable
class Reflection {
  final int before;
  final int after;
  final bool isVertical;

  Reflection({
    required this.before,
    required this.after,
    required this.isVertical,
  });

  int get summarize {
    if (isVertical) {
      return after;
    } else {
      return after * 100;
    }
  }

  @override
  String toString() {
    return '${isVertical ? "vertical" : "horizontal"} $before<->$after';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reflection &&
          runtimeType == other.runtimeType &&
          before == other.before &&
          after == other.after &&
          isVertical == other.isVertical;

  @override
  int get hashCode => before.hashCode ^ after.hashCode ^ isVertical.hashCode;
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  Future<List<NotePattern>> parseInput(Stream<String> input) async {
    final notes = <NotePattern>[];
    final currentPattern = <String>[];
    await for (final line in input) {
      if (line.isEmpty) {
        notes.add(NotePattern.fromLines(currentPattern));
        currentPattern.clear();
        continue;
      }

      currentPattern.add(line);
    }

    notes.add(NotePattern.fromLines(currentPattern));

    return notes;
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final notes = await parseInput(input);
    return notes
        .map((pattern) => pattern.findReflection())
        .map((reflection) => reflection.summarize)
        .reduce((a, b) => a + b);
  }
}

const day = Day(
  PartOne(),
);
