import 'dart:math';

import 'package:meta/meta.dart';

extension CharIterable on String {
  Iterable<String> get chars sync* {
    for (var i = 0; i < length; i += 1) {
      yield this[i];
    }
  }
}

@immutable
class Vector {
  static const Vector zero = Vector();
  static const Vector north = Vector(y: -1);
  static const Vector east = Vector(x: 1);
  static const Vector south = Vector(y: 1);
  static const Vector west = Vector(x: -1);
  static const Iterable<Vector> starDirections = [
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
    return Vector(
      x: x + other.x,
      y: y + other.y,
    );
  }

  Vector operator -(Vector other) {
    return Vector(
      x: x - other.x,
      y: y - other.y,
    );
  }

  Vector abs() {
    return Vector(
      x: x.abs(),
      y: y.abs(),
    );
  }

  int manhattanNorm() {
    final abs = this.abs();
    return abs.x + abs.y;
  }

  double norm(int p) {
    final sum = pow(x.abs(), p) + pow(y.abs(), p);

    if (p == 2) {
      // Special case for Euclidean norm in hopes that sqrt is faster than pow(n, 1/2)
      return sqrt(sum);
    }

    return pow(sum, 1 / p) as double;
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
