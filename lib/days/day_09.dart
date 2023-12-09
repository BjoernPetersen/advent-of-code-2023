import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

final linePattern = RegExp(r'(-?\d+)');

List<int> parseLine(String line) => linePattern
    .allMatches(line)
    .map((e) => e.group(1)!)
    .map(int.parse)
    .toList(growable: false);

@immutable
final class PartOne implements IntPart {
  const PartOne();

  int extrapolateValue(List<int> row) {
    if (row.every((i) => i == 0)) {
      return 0;
    }

    final diffs =
        List.generate(row.length - 1, (index) => row[index + 1] - row[index]);
    final result = row.last + extrapolateValue(diffs);
    return result;
  }

  @override
  Future<int> calculate(Stream<String> input) {
    return input.map(parseLine).map(extrapolateValue).reduce((a, b) => a + b);
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  int extrapolateValue(List<int> row) {
    if (row.every((i) => i == 0)) {
      return 0;
    }

    final diffs =
        List.generate(row.length - 1, (index) => row[index + 1] - row[index]);
    final result = row.first - extrapolateValue(diffs);
    return result;
  }

  @override
  Future<int> calculate(Stream<String> input) {
    return input.map(parseLine).map(extrapolateValue).reduce((a, b) => a + b);
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
