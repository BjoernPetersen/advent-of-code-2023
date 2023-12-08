import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:aoc/day.dart';
import 'package:async/async.dart';
import 'package:meta/meta.dart';

@immutable
class NumMapping implements Comparable<NumMapping> {
  final int from;
  final int to;
  final int length;

  const NumMapping({
    required this.from,
    required this.to,
    required this.length,
  });

  NumMapping invert() {
    return NumMapping(
      from: to,
      to: from,
      length: length,
    );
  }

  factory NumMapping.fromString(String line) {
    final [to, from, length] = line.split(' ');
    return NumMapping(
      from: int.parse(from),
      to: int.parse(to),
      length: int.parse(length),
    );
  }

  int get effect => to - from;

  int operator [](int from) {
    final difference = from - this.from;
    if (difference >= 0 && difference < length) {
      return to + difference;
    } else {
      return -1;
    }
  }

  (int, int) get fromBounds => (from, from + length - 1);

  (int, int) get toBounds => (to, to + length - 1);

  @override
  int compareTo(NumMapping other) {
    return from.compareTo(other.from);
  }
}

@immutable
class NumMap {
  final String name;
  final List<NumMapping> mappings;

  const NumMap(this.name, this.mappings);

  int operator [](int from) {
    // TODO: could order mappings to break early
    for (final mapping in mappings) {
      final value = mapping[from];
      if (value > -1) {
        return value;
      }
    }
    return from;
  }
}

@immutable
class Almanac {
  final List<int> seeds;
  final List<NumMap> maps;

  const Almanac(this.seeds, this.maps);

  Iterable<int> get seedsPartTwo sync* {
    for (var i = 0; i < seeds.length; i += 2) {
      final from = seeds[i];
      final length = seeds[i + 1];
      for (var seed = from; seed < from + length; seed += 1) {
        yield seed;
      }
    }
  }

  static Future<Almanac> fromInput(Stream<String> lines) async {
    final seeds = <int>[];
    final maps = <NumMap>[];
    var currentName = '';
    var currentMappings = <NumMapping>[];
    await lines.forEach((line) {
      if (seeds.isEmpty) {
        line.split(': ')[1].split(' ').map(int.parse).forEach(seeds.add);
        return;
      }

      if (line.isEmpty) {
        if (currentMappings.isNotEmpty) {
          maps.add(NumMap(currentName, currentMappings));
          currentMappings = [];
          currentName = '';
        }
        return;
      }

      if (currentMappings.isEmpty && currentName.isEmpty) {
        currentName = line.substring(0, line.length - 5);
        return;
      }

      currentMappings.add(NumMapping.fromString(line));
    });

    maps.add(NumMap(currentName, currentMappings));
    return Almanac(seeds, maps);
  }

  int findLocationNumber(int seed) {
    var currentNum = seed;
    for (final map in maps) {
      currentNum = map[currentNum];
    }
    return currentNum;
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final almanac = await Almanac.fromInput(input);
    return almanac.seeds
        .map(almanac.findLocationNumber)
        .reduce((value, element) => value > element ? element : value);
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final almanac = await Almanac.fromInput(input);

    // The following is a hellish version of:
    // return almanac.seedsPartTwo.map(almanac.findLocationNumber).reduce(min);

    final seeds = almanac.seeds;
    final ranges = List.generate(
      seeds.length ~/ 2,
      (index) => SeedRange(
        from: seeds[index * 2],
        length: seeds[index * 2 + 1],
      ),
      growable: false,
    );

    final slices = ranges.expand((range) => range.slices).iterator;

    final calculators = List.generate(
      Platform.numberOfProcessors,
      (index) => Calculator(id: index, almanac: almanac),
    );

    // Await spawning and setup
    await Future.wait(
      [for (final calculator in calculators) calculator.start()],
    );

    // A group with the outputs of all calculators
    final outputGroup = StreamGroup.merge(calculators.map((c) => c.output));

    var doneCalculatorCount = 0;
    for (final calculator in calculators) {
      // initial numbers
      if (!slices.moveNext()) {
        calculator.close();
        doneCalculatorCount += 1;
        continue;
      }
      calculator.input.send(slices.current.asTuple());
    }

    final results = <int>[];
    final completer = Completer();
    unawaited(outputGroup.forEach((output) {
      final (id, location) = output;
      results.add(location);
      if (slices.moveNext()) {
        calculators[id].input.send(slices.current.asTuple());
        return;
      }

      doneCalculatorCount += 1;
      if (doneCalculatorCount == calculators.length) {
        completer.complete();
      }
    }));

    await completer.future;
    for (var c in calculators) {
      c.close();
    }

    return results.reduce(min);
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);

@immutable
class SeedRange {
  final int from;
  final int length;

  const SeedRange({required this.from, required this.length});

  factory SeedRange.fromTuple((int, int) tuple) =>
      SeedRange(from: tuple.$1, length: tuple.$2);

  (int, int) asTuple() => (from, length);

  Iterable<SeedRange> get slices sync* {
    var from = this.from;
    var length = this.length;
    final batch = 10000;
    while (length > batch) {
      yield SeedRange(from: from, length: batch);
      from += batch;
      length -= batch;
    }

    yield SeedRange(from: from, length: length);
  }

  Iterable<int> get seeds sync* {
    for (var seed = from; seed < from + length; seed += 1) {
      yield seed;
    }
  }

  @override
  String toString() {
    return '$from -> ${from + length - 1}';
  }
}

@immutable
class IsolateEnv {
  final Almanac almanac;
  final int id;

  IsolateEnv({required this.almanac, required this.id});

  Future<void> _calculate(SendPort send) async {
    final ReceivePort incoming = ReceivePort('$id: Calculator in');
    send.send(incoming.sendPort);

    try {
      await incoming.forEach((element) {
        final range = SeedRange.fromTuple(element);
        final minimumLocation =
            range.seeds.map(almanac.findLocationNumber).reduce(min);
        send.send((id, minimumLocation));
      });
    } finally {
      incoming.close();
    }
  }

  Future<Isolate> spawn(SendPort sendPort) {
    return Isolate.spawn<SendPort>(_calculate, sendPort);
  }
}

@immutable
class Calculator {
  final Almanac almanac;
  final int id;
  late final SendPort input;
  final ReceivePort _output;
  late final Stream<(int, int)> output;

  Calculator({required this.id, required this.almanac})
      : _output = ReceivePort('$id: Calculator out');

  Future<void> start() async {
    final isolateEnv = IsolateEnv(almanac: almanac, id: id);
    await isolateEnv.spawn(_output.sendPort);
    final controller = StreamController<(int, int)>();
    output = controller.stream;

    final completer = Completer<void>();
    unawaited(_pumpToController(controller, completer));

    await completer.future;
  }

  Future<void> _pumpToController(
    StreamController<(int, int)> controller,
    Completer notifyInputPortReceived,
  ) async {
    await _output.forEach((element) {
      if (!notifyInputPortReceived.isCompleted) {
        input = element;
        notifyInputPortReceived.complete();
      } else {
        controller.add(element);
      }
    });
    await controller.close();
  }

  void close() {
    _output.close();
  }
}
