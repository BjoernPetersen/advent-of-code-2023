import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

typedef NodeMap = Map<String, (String, String)>;

@immutable
class State {
  final int programCounter;
  final String currentNode;
  final NodeMap nodes;

  State._(this.programCounter, this.currentNode, this.nodes);

  State.initial(
    this.nodes, {
    this.currentNode = 'AAA',
  }) : programCounter = 0;

  State nextNode(String node) {
    return State._(programCounter + 1, node, nodes);
  }
}

@immutable
final class Program {
  final String raw;

  const Program(this.raw);

  State step(State state) {
    final instruction = raw[state.programCounter % raw.length];
    final (left, right) = state.nodes[state.currentNode]!;
    if (instruction == 'R') {
      return state.nextNode(right);
    } else {
      return state.nextNode(left);
    }
  }
}

Future<(Program, NodeMap)> parseInput(Stream<String> input) async {
  Program? program;
  final NodeMap nodes = {};
  final mappingPattern = RegExp(r'^(\w+) = \((\w+), (\w+)\)$');
  await input.forEach((line) {
    if (line.isEmpty) {
      return;
    }

    if (program == null) {
      program = Program(line);
      return;
    }

    final match = mappingPattern.firstMatch(line)!;
    nodes[match.group(1)!] = (match.group(2)!, match.group(3)!);
  });

  return (program!, nodes);
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (program, nodes) = await parseInput(input);
    var state = State.initial(nodes);
    while (state.currentNode != 'ZZZ') {
      state = program.step(state);
    }
    return state.programCounter;
  }
}

@immutable
class Cycle {
  final int start;
  final int length;

  Cycle({required this.start, required this.length});

  @override
  String toString() {
    return 'Start: $start, length: $length';
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  int findGcd(int a, int b) {
    if (b == 0) {
      return a;
    } else {
      return findGcd(b, a % b);
    }
  }

  int findLcm(int a, int b) {
    return (a * b) ~/ findGcd(a, b);
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final (program, nodes) = await parseInput(input);
    final startingNodes = nodes.keys.where((n) => n.endsWith('A'));
    final cycles = <Cycle>[];

    for (final startingNode in startingNodes) {
      final seenEnds = <String, int>{};
      var state = State.initial(nodes, currentNode: startingNode);
      while (!seenEnds.containsKey(state.currentNode)) {
        if (state.currentNode.endsWith('Z')) {
          seenEnds[state.currentNode] = state.programCounter;
        }
        state = program.step(state);
      }
      final cycleLength = state.programCounter - seenEnds[state.currentNode]!;
      final cycle = Cycle(
        start: state.programCounter - cycleLength,
        length: cycleLength,
      );
      cycles.add(cycle);
    }

    if (cycles.any((c) => c.start != c.length)) {
      throw Exception(
          "I'm not implementing that, my input matches this assumption");
    }
    return cycles.map((c) => c.length).reduce(findLcm);
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
