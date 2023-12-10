import 'package:aoc/day.dart';
import 'package:aoc/days/util.dart';
import 'package:meta/meta.dart';

@immutable
class Vector {
  final int x;
  final int y;

  const Vector(this.x, this.y);

  Vector operator +(Vector other) {
    return Vector(x + other.x, y + other.y);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vector &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() {
    return '($x, $y)';
  }
}

@immutable
class Pipe {
  final String char;
  final Vector location;
  final List<Vector> _directions;

  const Pipe._(this.char, this.location, this._directions);

  factory Pipe.fromChar(String char, Vector location) {
    final directions = switch (char) {
      '|' => [Vector(0, -1), Vector(0, 1)],
      '-' => [Vector(1, 0), Vector(-1, 0)],
      'L' => [Vector(0, -1), Vector(1, 0)],
      'J' => [Vector(-1, 0), Vector(0, -1)],
      '7' => [Vector(-1, 0), Vector(0, 1)],
      'F' => [Vector(1, 0), Vector(0, 1)],
      'S' => [Vector(1, 0), Vector(0, 1), Vector(-1, 0), Vector(0, -1)],
      '.' => <Vector>[],
      _ => throw ArgumentError.value(char, 'char', 'invalid pipe')
    };

    return Pipe._(char, location, directions);
  }

  bool get isStartingPipe => char == 'S';

  Iterable<Vector> getOutflows(Vector? from) {
    final outflows = _directions
        .map((v) => location + v)
        .where((v) => v != from)
        .toList(growable: false);

    if (from != null && outflows.length == _directions.length) {
      // Not connected to from
      return [];
    }

    return outflows;
  }

  @override
  String toString() {
    return '$char ($location)';
  }
}

@immutable
class Grid {
  final Vector _startingLocation;
  final List<List<Pipe>> _pipes;

  const Grid._({
    required Vector startingPosition,
    required List<List<Pipe>> pipes,
  })  : _startingLocation = startingPosition,
        _pipes = pipes;

  static Future<Grid> fromInput(Stream<String> input) async {
    final pipes = <List<Pipe>>[];
    late final Vector startingLocation;
    await input.forEach((line) {
      final row = <Pipe>[];
      final y = pipes.length;
      for (final (x, char) in line.chars.indexed) {
        final location = Vector(x, y);
        if (char == 'S') {
          startingLocation = location;
        }

        row.add(Pipe.fromChar(char, location));
      }
      pipes.add(row);
    });

    return Grid._(
      startingPosition: startingLocation,
      pipes: pipes,
    );
  }

  Pipe? operator [](Vector vector) {
    if (vector.y >= _pipes.length) {
      return null;
    }
    final row = _pipes[vector.y];
    if (vector.x >= row.length) {
      return null;
    }
    return row[vector.x];
  }

  Pipe get startingPipe => this[_startingLocation]!;
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  int walk(
    Grid grid, {
    required int steps,
    required Pipe currentPipe,
    Pipe? previousPipe,
  }) {
    if (steps > 0 && currentPipe.isStartingPipe) {
      return steps;
    }

    for (final outflow in currentPipe.getOutflows(previousPipe?.location)) {
      final outPipe = grid[outflow];
      if (outPipe == null) {
        continue;
      }

      final outResult = walk(
        grid,
        steps: steps + 1,
        currentPipe: outPipe,
        previousPipe: currentPipe,
      );
      if (outResult > -1) {
        return outResult;
      }
    }

    return -1;
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final grid = await Grid.fromInput(input);
    final startingPipe = grid.startingPipe;
    return walk(grid, steps: 0, currentPipe: startingPipe) ~/ 2;
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    return 0;
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
