import 'package:aoc/days/day_01.dart' as day01;
import 'package:aoc/days/day_02.dart' as day02;
import 'package:aoc/days/day_03.dart' as day03;
import 'package:aoc/days/day_04.dart' as day04;
import 'package:aoc/days/day_05.dart' as day05;
import 'package:aoc/days/day_06.dart' as day06;
import 'package:aoc/days/day_07.dart' as day07;
import 'package:aoc/days/day_08.dart' as day08;
import 'package:aoc/days/day_09.dart' as day09;
import 'package:aoc/days/day_10.dart' as day10;
import 'package:meta/meta.dart';

const List<Day<Part, Part>> _days = [
  day01.day,
  day02.day,
  day03.day,
  day04.day,
  day05.day,
  day06.day,
  day07.day,
  day08.day,
  day09.day,
  day10.day,
];

@immutable
sealed class Part<T> {
  Future<T> calculate(Stream<String> input);
}

@immutable
abstract interface class IntPart implements Part<int> {}

@immutable
abstract interface class StringPart implements Part<String> {}

@immutable
final class Day<A extends Part, B extends Part> {
  final A partOne;
  final B? partTwo;

  const Day(
    this.partOne, [
    this.partTwo,
  ]);
}

Day<Part, Part> getDay(int day) => _days[day - 1];

extension StringResult on Part {
  Future<String> calculateString(Stream<String> input) async {
    final String result;
    switch (this) {
      case StringPart():
        final typed = this as StringPart;
        result = await typed.calculate(input);
      case IntPart():
        final typed = this as IntPart;
        final intValue = await typed.calculate(input);
        result = intValue.toString();
    }
    return result;
  }
}
