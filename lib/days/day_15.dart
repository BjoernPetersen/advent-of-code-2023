import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    return 0;
  }
}

const day = Day(
  PartOne(),
);
