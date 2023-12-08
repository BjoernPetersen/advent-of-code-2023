import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

typedef NodeMap = Map<String, (String, String)>;

@immutable
class State {
  final int programCounter;
  final String currentNode;
  final NodeMap nodes;

  State._(this.programCounter, this.currentNode, this.nodes);

  State.initial(this.nodes)
      : programCounter = 0,
        currentNode = 'AAA';

  State nextNode(String node) {
    return State._(programCounter + 1, node, nodes);
  }

  bool get isFinished => currentNode == 'ZZZ';
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
    while (!state.isFinished) {
      state = program.step(state);
    }
    return state.programCounter;
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (program, nodes) = await parseInput(input);
    var state = State.initial(nodes);
    while (!state.isFinished) {
      state = program.step(state);
    }
    return state.programCounter;
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
