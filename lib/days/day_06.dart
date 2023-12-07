import 'dart:math';

import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

@immutable
class Race {
  final int time;
  final int distance;

  Race({required this.time, required this.distance});

  (int, int) get winningRange {
    // It's been a long time since Abitur.
    final base = time / 2;
    final modifier = sqrt(pow(time / 2, 2) - distance);
    final lower = base - modifier;
    final upper = base + modifier;
    return (lower.truncate() + 1, upper.ceil() - 1);
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  List<int> parseNumberRow(String line) {
    final pattern = RegExp(r'(\d+)');
    return pattern
        .allMatches(line)
        .map((match) => match.group(1)!)
        .map(int.parse)
        .toList(growable: false);
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final numbersRows = await input.map(parseNumberRow).toList();
    final races = <Race>[];
    for (var index = 0; index < numbersRows[0].length; index += 1) {
      races.add(Race(
        time: numbersRows[0][index],
        distance: numbersRows[1][index],
      ));
    }

    return races
        .map((e) => e.winningRange)
        .map((range) => range.$2 - range.$1 + 1)
        .reduce((a, b) => a * b);
  }
}

final class PartTwo implements IntPart {
  const PartTwo();

  int parseNumberRow(String line) {
    final pattern = RegExp(r'(\d+)');
    final joined =
        pattern.allMatches(line).map((match) => match.group(1)!).join();
    return int.parse(joined);
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final numbers = await input.map(parseNumberRow).toList();
    final race = Race(
      time: numbers[0],
      distance: numbers[1],
    );

    final (minPress, maxPress) = race.winningRange;
    return maxPress - minPress + 1;
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
