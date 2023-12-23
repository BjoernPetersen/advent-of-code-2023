import 'dart:math';

import 'package:aoc/day.dart';
import 'package:aoc/days/util.dart';
import 'package:meta/meta.dart';

class Grid<T> {
  final List<List<T>> _grid;
  final int width;

  int get height => _grid.length;

  Grid(this._grid) : width = _grid[0].length;

  Grid.generate({
    required this.width,
    required int height,
    required T Function(Vector position) generator,
  }) : _grid = List.generate(
          height,
          (y) => List.generate(
            width,
            (x) => generator(Vector(x: x, y: y)),
            growable: false,
          ),
          growable: false,
        );

  T operator [](Vector pos) => _grid[pos.y][pos.x];

  void operator []=(Vector pos, T value) => _grid[pos.y][pos.x] = value;

  bool contains(Vector pos) {
    return pos.x >= 0 && pos.y >= 0 && pos.x < width && pos.y < height;
  }

  Iterable<List<T>> get rows sync* {
    for (final row in _grid) {
      yield row;
    }
  }

  Iterable<Iterable<T>> get columns sync* {
    for (var x = 0; x < width; x += 1) {
      yield Iterable.generate(height, (y) => _grid[y][x]);
    }
  }

  @override
  String toString() {
    return rows.map((row) => row.map((e) => e.toString()).join()).join('\n');
  }
}

@immutable
sealed class Mirror {
  final Vector position;

  const Mirror(this.position);

  Iterable<Vector> forwardRay(Vector from);
}

@immutable
final class EmptyMirror extends Mirror {
  const EmptyMirror(super.position);

  @override
  Iterable<Vector> forwardRay(Vector from) {
    return [position * 2 - from];
  }

  @override
  String toString() => '.';
}

@immutable
final class DiagonalMirror extends Mirror {
  final bool isTopDown;

  const DiagonalMirror(
    super.position, {
    required this.isTopDown,
  });

  @override
  Iterable<Vector> forwardRay(Vector from) {
    final ray = position - from;
    return [position + ray.rotate(clockwise: isTopDown == ray.isHorizontal)];
  }

  @override
  String toString() => isTopDown ? r'\' : '/';
}

@immutable
final class SplitterMirror extends Mirror {
  final bool isVertical;

  SplitterMirror(super.position, {required this.isVertical});

  @override
  Iterable<Vector> forwardRay(Vector from) sync* {
    final ray = position - from;
    if (ray.isVertical == isVertical) {
      yield position + ray;
    } else {
      yield position + ray.rotate(clockwise: true);
      yield position + ray.rotate(clockwise: false);
    }
  }

  @override
  String toString() => isVertical ? '|' : '-';
}

Future<Grid<Mirror>> parseGrid(Stream<String> input) async {
  final grid = <List<Mirror>>[];

  var y = 0;
  await for (final line in input) {
    final row = <Mirror>[];
    for (final (x, char) in line.chars.indexed) {
      final position = Vector(x: x, y: y);
      final mirror = switch (char) {
        '.' => EmptyMirror(position),
        '-' => SplitterMirror(position, isVertical: false),
        '|' => SplitterMirror(position, isVertical: true),
        '/' => DiagonalMirror(position, isTopDown: false),
        r'\' => DiagonalMirror(position, isTopDown: true),
        _ => throw ArgumentError('Invalid char: $char'),
      };
      row.add(mirror);
    }
    y += 1;
    grid.add(row);
  }

  return Grid(grid);
}

void visit(
  Grid<Mirror> grid,
  Set<(Vector, Vector)> visited, {
  required Vector from,
  required Vector position,
}) {
  if (!visited.add((from, position))) {
    return;
  }

  final mirror = grid[position];
  for (final next in mirror.forwardRay(from)) {
    if (grid.contains(next)) {
      visit(
        grid,
        visited,
        from: position,
        position: next,
      );
    }
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final grid = await parseGrid(input);
    final visited = <(Vector, Vector)>{};
    visit(
      grid,
      visited,
      position: Vector.zero,
      from: Vector(x: -1, y: 0),
    );

    final positions = visited.map((e) => e.$2).toSet();

    return positions.length;
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  Iterable<(Vector, Vector)> findStartingPositions(
      int width, int height) sync* {
    for (var x = 0; x < width; x += 1) {
      final topStartPosition = Vector(x: x, y: 0);
      yield (topStartPosition + Vector.north, topStartPosition);

      final bottomFromPosition = Vector(x: x, y: height);
      yield (bottomFromPosition, bottomFromPosition + Vector.north);
    }

    for (var y = 0; y < height; y += 1) {
      final leftStartPosition = Vector(x: 0, y: y);
      yield (leftStartPosition + Vector.west, leftStartPosition);

      final rightFromPosition = Vector(x: width, y: y);
      yield (rightFromPosition, rightFromPosition + Vector.west);
    }
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final grid = await parseGrid(input);

    var maxEnergized = 0;

    for (final (from, to) in findStartingPositions(grid.width, grid.height)) {
      final visited = <(Vector, Vector)>{};
      visit(
        grid,
        visited,
        position: to,
        from: from,
      );

      final positions = visited.map((e) => e.$2).toSet();
      maxEnergized = max(maxEnergized, positions.length);
    }

    return maxEnergized;
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
