import 'package:aoc/day.dart';
import 'package:test/test.dart';

import '../input_helper.dart';

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
      test('input passes', () {
        final reader = getInputReader(dayNum);
        expect(part.calculate(reader.readLines()), completion(54632));
      });
    });
    group('part 2', () {
      final part = day.partTwo as IntPart;
      test('example 2 passes', () {
        final reader = getExampleReader(dayNum, '2');
        expect(part.calculate(reader.readLines()), completion(281));
      });
      test('input passes', () {
        final reader = getInputReader(dayNum);
        expect(part.calculate(reader.readLines()), completion(54019));
      });
      test('mangleddigits', () {
        final input = Stream.value('6oneeightwod');
        expect(part.calculate(input), completion(62));
      });
    });
  });
}
