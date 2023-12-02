import 'package:aoc/days/day_01.dart' as day01;
import 'package:meta/meta.dart';

const List<Day<Part, Part>> _days = [
  day01.day,
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

extension StringResult on Part<Object> {
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
