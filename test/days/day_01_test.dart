import 'package:aoc/day.dart';
import 'package:test/test.dart';

import '../examples.dart';

void main() {
  final dayNum = 1;
  final day = getDay(dayNum);

  group('day $dayNum', () {
    group('part 1', () {
      final part = day.partOne as IntPart;
      test('example 1 passes', () {
        final reader = getExampleReader(dayNum, '1');
        expect(part.calculate(reader.readLines()), completion(142));
      });
    });
  });
}
