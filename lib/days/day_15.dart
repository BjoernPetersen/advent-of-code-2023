import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

int hash(String input) {
  var result = 0;
  for (final charCode in input.codeUnits) {
    result += charCode;
    result *= 17;
    result %= 256;
  }
  return result;
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final line = await input.single;
    return line.split(',').map(hash).reduce((a, b) => a + b);
  }
}

class BoxItem {
  final String label;
  int value;

  BoxItem({required this.label, required this.value});
}

class HashMap {
  final List<List<BoxItem>> _boxes;

  HashMap(int capacity) : _boxes = List.generate(capacity, (_) => []);

  void operator []=(String label, int value) {
    final box = _boxes[hash(label)];
    final item = box.where((element) => element.label == label).firstOrNull;
    if (item == null) {
      box.add(BoxItem(label: label, value: value));
    } else {
      item.value = value;
    }
  }

  void remove(String label) =>
      _boxes[hash(label)].removeWhere((e) => e.label == label);

  Iterable<String> get labels {
    return _boxes.expand((element) => element.map((e) => e.label));
  }

  int calculateFocusingPower(String label) {
    final boxNumber = hash(label);
    final slotNumber = _boxes[boxNumber].indexWhere((e) => e.label == label);
    final focalLength = _boxes[boxNumber][slotNumber].value;
    return (boxNumber + 1) * (slotNumber + 1) * focalLength;
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final line = await input.single;
    final map = HashMap(256);
    final regex = RegExp(r'([a-z]+)(-|=(\d+))');
    for (final instruction in line.split(',')) {
      final match = regex.matchAsPrefix(instruction)!;
      final label = match.group(1)!;
      final focalLength = match.group(3);
      if (focalLength == null) {
        map.remove(label);
      } else {
        final value = int.parse(focalLength);
        map[label] = value;
      }
    }

    return map.labels.map(map.calculateFocusingPower).reduce((a, b) => a + b);
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
