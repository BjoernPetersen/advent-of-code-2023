import 'package:aoc/day.dart';
import 'package:aoc/days/day_11.dart';
import 'package:test/test.dart';

import '../input_helper.dart';

void main() {
  final dayNum = 11;
  final day = getDay(dayNum);

  group('day $dayNum', () {
    group('part 1', () {
      final part = day.partOne as IntPart;

      for (final (example, expectedResult) in [
        ('1', 374),
      ]) {
        test('example $example passes', () {
          final reader = getExampleReader(dayNum, example);
          expect(
              part.calculate(reader.readLines()), completion(expectedResult));
        });
      }
      test('input passes', () {
        final reader = getInputReader(dayNum);
        expect(part.calculate(reader.readLines()), completion(10231178));
      });
    });
    group(
      'part 2',
      () {
        late final IntPart part;

        setUpAll(() {
          part = day.partTwo as IntPart;
        });

        for (final (example, factor, expectedResult) in [
          ('1', 10, 1030),
          ('1', 100, 8410),
        ]) {
          test('example $example passes with factor $factor', () async {
            final reader = getExampleReader(dayNum, example);
            final universe = await Universe.fromInput(
              reader.readLines(),
              expansionFactor: factor,
            );
            expect(universe.sumOfGalaxyPairDistances, expectedResult);
          });
        }
        test('input passes', () {
          final reader = getInputReader(dayNum);
          expect(part.calculate(reader.readLines()), completion(622120986954));
        });
      },
      skip: false,
    );
  });
}
