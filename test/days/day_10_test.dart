import 'package:aoc/day.dart';
import 'package:test/test.dart';

import '../input_helper.dart';

void main() {
  final dayNum = 10;
  final day = getDay(dayNum);

  group('day $dayNum', () {
    group('part 1', () {
      final part = day.partOne as IntPart;

      for (final (example, expectedResult) in [
        ('1-simple-pure-loop', 4),
        ('1-simple', 4),
        ('2-complex-pure-loop', 8),
        ('2-complex', 8),
      ]) {
        test('example $example passes', () {
          final reader = getExampleReader(dayNum, example);
          expect(
              part.calculate(reader.readLines()), completion(expectedResult));
        });
      }
      test('input passes', () {
        final reader = getInputReader(dayNum);
        expect(part.calculate(reader.readLines()), completion(1884768153));
      });
    });
    group(
      'part 2',
      () {
        late final IntPart part;

        setUpAll(() {
          part = day.partTwo as IntPart;
        });

        for (final (example, expectedResult) in [
          ('1', 114),
        ]) {
          test('example $example passes', () {
            final reader = getExampleReader(dayNum, example);
            expect(
                part.calculate(reader.readLines()), completion(expectedResult));
          });
        }
        test('input passes', () {
          final reader = getInputReader(dayNum);
          expect(part.calculate(reader.readLines()), completion(1031));
        });
      },
      skip: true,
    );
  });
}
