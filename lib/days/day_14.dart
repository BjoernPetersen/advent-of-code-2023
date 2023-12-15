import 'package:aoc/day.dart';
import 'package:aoc/days/util.dart';
import 'package:meta/meta.dart';

@immutable
class Rock {
  final bool isRound;

  const Rock({required this.isRound});

  static Rock? fromSymbol(String symbol) {
    return switch (symbol) {
      '.' => null,
      'O' => Rock(isRound: true),
      '#' => Rock(isRound: false),
      _ => throw ArgumentError('Invalid symbol: $symbol')
    };
  }
}

@immutable
class PositionedRock {
  final Rock rock;
  final Vector position;

  const PositionedRock({required this.rock, required this.position});

  int calculateNorthLoad({required int platformHeight}) {
    if (!rock.isRound) {
      return 0;
    }

    return platformHeight - position.y;
  }
}

@immutable
class Platform {
  final int width;
  final List<List<Rock?>> _rocks;

  Platform._(this._rocks) : width = _rocks.first.length;

  static Future<Platform> fromInput(Stream<String> input) async {
    final result = <List<Rock?>>[];
    await for (final line in input) {
      result.add(line.chars.map(Rock.fromSymbol).toList());
    }
    return Platform._(result);
  }

  Rock? operator [](Vector position) {
    return _rocks[position.y][position.x];
  }

  bool contains(Vector position) {
    return position.x >= 0 &&
        position.x < width &&
        position.y >= 0 &&
        position.y < _rocks.length;
  }

  Platform tilt(Vector direction) {
    final width = this.width;
    final height = _rocks.length;
    final List<List<Rock?>> rocks = List.generate(
      height,
      (index) => List.filled(width, null),
      growable: false,
    );

    final int yStart;
    final int yDirection;
    final int yEnd;

    if (direction.y < 0) {
      yStart = 0;
      yDirection = 1;
      yEnd = height;
    } else {
      yStart = height - 1;
      yDirection = -1;
      yEnd = -1;
    }

    final int xStart;
    final int xDirection;
    final int xEnd;

    if (direction.x < 0) {
      xStart = 0;
      xDirection = 1;
      xEnd = width;
    } else {
      xStart = width - 1;
      xDirection = -1;
      xEnd = -1;
    }

    for (var y = yStart; y != yEnd; y += yDirection) {
      final row = rocks[y];
      for (var x = xStart; x != xEnd; x += xDirection) {
        final position = Vector(x: x, y: y);
        final rock = this[position];
        row[x] = rock;
        if (rock?.isRound ?? false) {
          Vector blockerPosition;
          for (blockerPosition = position + direction;
              contains(blockerPosition);
              blockerPosition += direction) {
            final existingRock = rocks[blockerPosition.y][blockerPosition.x];
            if (existingRock != null) {
              break;
            }
          }
          final newPosition = blockerPosition - direction;
          row[x] = null;
          rocks[newPosition.y][newPosition.x] = rock;
        }
      }
    }

    return Platform._(rocks);
  }

  Iterable<PositionedRock> get rocks sync* {
    for (var y = 0; y < _rocks.length; y += 1) {
      for (var x = 0; x < width; x += 1) {
        final rock = _rocks[y][x];
        if (rock != null) {
          yield PositionedRock(rock: rock, position: Vector(x: x, y: y));
        }
      }
    }
  }

  int get totalLoad {
    return rocks
        .map((rock) => rock.calculateNorthLoad(platformHeight: _rocks.length))
        .reduce((a, b) => a + b);
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final platform = await Platform.fromInput(input);
    return platform.tilt(Vector.north).totalLoad;
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    var platform = await Platform.fromInput(input);

    final cycleDirections = [
      Vector.north,
      Vector.west,
      Vector.south,
      Vector.east
    ];

    for (var i = 0; i < 1000000000; i += 1) {
      if (i % 100000 == 0) {
        print(i);
      }
      for (final direction in cycleDirections) {
        platform = platform.tilt(direction);
      }
    }

    return platform.totalLoad;
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
