import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

@immutable
class PartOne implements IntPart {
  const PartOne();

  int calculateLine(String line) {
    int result = 0;

    final min = '0'.codeUnitAt(0);
    final max = '9'.codeUnitAt(0);

    final runes = line.runes.toList(growable: false);
    for (final rune in runes) {
      if (rune >= min && rune <= max) {
        result = (rune - min) * 10;
        break;
      }
    }

    for (var index = runes.length - 1; index >= 0; index -= 1) {
      final rune = runes[index];
      if (rune >= min && rune <= max) {
        result += rune - min;
        break;
      }
    }

    return result;
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    return await input
        .map(calculateLine)
        .reduce((sum, element) => sum + element);
  }
}

@immutable
class PartTwo implements IntPart {
  static final values = {
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    for (var i = 0; i < 10; i += 1) i.toString(): i,
  };

  const PartTwo();

  int calculateLine(RegExp forwardRegex, RegExp backwardRegex, String line) {
    final firstMatch = forwardRegex.firstMatch(line)!.group(0)!;
    final lastMatch = backwardRegex.firstMatch(reverse(line))!.group(0)!;
    final result = values[firstMatch]! * 10 + values[reverse(lastMatch)]!;
    return result;
  }

  String reverse(String input) {
    final buffer = StringBuffer();
    for (final charCode in input.codeUnits.reversed) {
      buffer.writeCharCode(charCode);
    }
    return buffer.toString();
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final writtenDigits = 'one|two|three|four|five|six|seven|eight|nine';
    final forwardRegex = RegExp('(\\d|$writtenDigits)');

    // This may *look* stupid,
    final backwardsRegex = RegExp('(\\d|${reverse(writtenDigits)})');

    return await input
        .map((line) => calculateLine(forwardRegex, backwardsRegex, line))
        .reduce((sum, element) => sum + element);
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
