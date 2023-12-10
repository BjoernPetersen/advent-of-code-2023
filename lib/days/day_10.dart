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

  Vector operator -(Vector other) {
    return Vector(x - other.x, y - other.y);
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
  final Vector location;
  final List<Vector> _directions;

  const Pipe._(this.location, this._directions);

  factory Pipe.fromNeighbors({
    required Vector location,
    required Vector inflow,
    required Vector outflow,
  }) {
    return Pipe._(
      location,
      [inflow - location, outflow - location],
    );
  }

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

    return Pipe._(location, directions);
  }

  bool get isStartingPipe => _directions.length > 2;

  Iterable<Vector> get allOutflows => _directions.map((v) => location + v);

  Vector? getOutflow(Vector inflow) {
    if (isStartingPipe) {
      throw UnsupportedError('Start pipe has multiple outflows');
    }

    return _directions
        .map((v) => location + v)
        .where((v) => v != inflow)
        .singleOrNull;
  }

  @override
  String toString() {
    return '$location';
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

List<Pipe> findLoop(Grid grid) {
  final startingPipe = grid.startingPipe;
  for (final initialOutflow in startingPipe.allOutflows) {
    // Summary: venture out in all directions from the start pipe until we hit the start pipe or a
    // dead end. No need to keep a stack since none of the pipes (except for the start pipe) branch.
    var loop = <Pipe>[];
    var previousPipe = startingPipe;
    var currentPipe = grid[initialOutflow];

    while (currentPipe != null && !currentPipe.isStartingPipe) {
      loop.add(currentPipe);
      final outflow = currentPipe.getOutflow(previousPipe.location);
      if (outflow == null) {
        // dead end
        currentPipe = null;
        break;
      }
      previousPipe = currentPipe;
      currentPipe = grid[outflow];
    }

    if (currentPipe == null) {
      continue;
    }

    final startReplacement = Pipe.fromNeighbors(
      location: grid.startingPipe.location,
      inflow: previousPipe.location,
      outflow: initialOutflow,
    );
    loop.add(startReplacement);
    return loop;
  }

  throw Exception('No loop found');
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final grid = await Grid.fromInput(input);
    return findLoop(grid).length ~/ 2;
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  int calculateArea(List<Pipe> loop) {
    // Shoelace formula (trapezoid)
    var sum = 0;
    for (var index = 0; index < loop.length; index += 1) {
      final vector = loop[index].location;
      final nextVector = loop[(index + 1) % loop.length].location;
      sum += (vector.y + nextVector.y) * (vector.x - nextVector.x);
    }
    return (sum ~/ 2).abs();
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final grid = await Grid.fromInput(input);
    final loop = findLoop(grid);
    final area = calculateArea(loop);
    // Pick's theorem
    return area - loop.length ~/ 2 + 1;
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
