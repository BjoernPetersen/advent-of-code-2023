import 'package:aoc/day.dart';
import 'package:test/test.dart';

import '../input_helper.dart';

void main() {
  final dayNum = 8;
  final day = getDay(dayNum);

  group('day $dayNum', () {
    group('part 1', () {
      final part = day.partOne as IntPart;
      test('example 1 passes', () {
        final reader = getExampleReader(dayNum, '1');
        expect(part.calculate(reader.readLines()), completion(2));
      });
      test('example 2 passes', () {
        final reader = getExampleReader(dayNum, '2');
        expect(part.calculate(reader.readLines()), completion(6));
      });
      test('input passes', () {
        final reader = getInputReader(dayNum);
        expect(part.calculate(reader.readLines()), completion(19783));
      });
    });
    group(
      'part 2',
      () {
        late final IntPart part;

        setUpAll(() {
          part = day.partTwo as IntPart;
        });

        test('example 3 passes', () {
          final reader = getExampleReader(dayNum, '3');
          expect(part.calculate(reader.readLines()), completion(6));
        });
        test('input passes', () {
          final reader = getInputReader(dayNum);
          expect(part.calculate(reader.readLines()), completion(9177460370549));
        });
      },
      skip: false,
    );
  });
}
