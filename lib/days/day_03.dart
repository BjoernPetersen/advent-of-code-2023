import 'dart:collection';

import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

@immutable
final class Vector {
  static const Vector zero = Vector();
  static const Iterable<Vector> allDirections = [
    Vector(x: 1),
    Vector(x: 1, y: 1),
    Vector(y: 1),
    Vector(x: -1, y: 1),
    Vector(x: -1),
    Vector(x: -1, y: -1),
    Vector(y: -1),
    Vector(x: 1, y: -1),
  ];

  final int x;
  final int y;

  const Vector({
    this.x = 0,
    this.y = 0,
  });

  Vector operator +(Vector other) {
    return Vector(x: x + other.x, y: y + other.y);
  }

  Vector operator -(Vector other) {
    return Vector(x: x - other.x, y: y - other.y);
  }

  @override
  bool operator ==(Object other) {
    return other is Vector && x == other.x && y == other.y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  Iterable<Vector> get neighbors sync* {
    for (final direction in allDirections) {
      yield this + direction;
    }
  }

  @override
  String toString() {
    return '($x, $y)';
  }
}

@immutable
class Line {
  final Vector start;
  final Vector end;

  const Line({required this.start, required this.end});

  bool contains(Vector point) {
    // Simplification since all our lines are horizontal
    if (point.y != start.y) {
      return false;
    }

    return point.x >= start.x && point.x <= end.x;
  }

  @override
  String toString() {
    return '(${start.x}->${end.x}, ${start.y})';
  }
}

@immutable
class Part {
  final Line location;
  final int number;

  const Part(this.location, this.number);
}

@immutable
class Schematic {
  static final _dotCodeUnit = '.'.codeUnitAt(0);
  static final _digitMin = '0'.codeUnitAt(0);
  static final _digitMax = '9'.codeUnitAt(0);

  final List<String> _schematic;
  final int width;

  int get height => _schematic.length;

  const Schematic._(this._schematic, this.width);

  static Future<Schematic> fromLines(Stream<String> lines) async {
    final schematic = await lines.toList();
    final width = schematic[0].length;
    return Schematic._(schematic, width);
  }

  Iterable<Vector> get points sync* {
    for (var y = 0; y < height; y += 1) {
      for (var x = 0; x < width; x += 1) {
        yield Vector(x: x, y: y);
      }
    }
  }

  bool contains(Vector point) {
    return point.x >= 0 && point.y >= 0 && point.x < width && point.y < height;
  }

  String operator [](Vector point) {
    if (!contains(point)) {
      throw ArgumentError.value(point, 'point', ['is outside of Schematic']);
    }

    return _schematic[point.y][point.x];
  }

  bool isSymbol(Vector point) {
    int char = this[point].codeUnitAt(0);
    return char != _dotCodeUnit && (char < _digitMin || char > _digitMax);
  }

  Iterable<Part> getParts() sync* {
    final regex = RegExp(r'(\d+)');
    for (final (y, line) in _schematic.indexed) {
      for (final match in regex.allMatches(line)) {
        final points = [
          for (var x = match.start; x < match.end; x += 1) Vector(x: x, y: y)
        ];
        final checkPoints = <Vector>{};
        for (final point in points) {
          for (final neighbor in point.neighbors) {
            if (contains(neighbor)) {
              checkPoints.add(neighbor);
            }
          }
        }
        checkPoints.removeAll(points);

        if (checkPoints.any(isSymbol)) {
          yield Part(
            Line(start: points.first, end: points.last),
            int.parse(match.group(1)!),
          );
        }
      }
    }
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final schematic = await Schematic.fromLines(input);
    return schematic.getParts().fold<int>(0, (sum, part) => sum + part.number);
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final schematic = await Schematic.fromLines(input);
    final parts = schematic.getParts().toList(growable: false);

    // Loops go brrrrrrrrrrr
    var sum = 0;
    for (final gear in schematic.points.where((v) => schematic[v] == '*')) {
      final adjacentNumbers = <int>[];
      for (final part in parts) {
        for (final neighbor in gear.neighbors) {
          if (part.location.contains(neighbor)) {
            adjacentNumbers.add(part.number);
            break;
          }
        }
      }
      if (adjacentNumbers.length == 2) {
        sum += adjacentNumbers.reduce((a, b) => a * b);
      }
    }

    return sum;
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
