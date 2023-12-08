import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

typedef NodeMap = Map<String, (String, String)>;

@immutable
class State {
  final int programCounter;
  final List<String> currentNodes;
  final NodeMap nodes;

  State._(this.programCounter, this.currentNodes, this.nodes);

  State.initialPartOne(this.nodes)
      : programCounter = 0,
        currentNodes = const ['AAA'];

  State.initialPartTwo(this.nodes)
      : programCounter = 0,
        currentNodes =
            nodes.keys.where((n) => n.endsWith('A')).toList(growable: false);

  State nextNodes(List<String> nextNodes) {
    return State._(programCounter + 1, nextNodes, nodes);
  }
}

@immutable
final class Program {
  final String raw;

  const Program(this.raw);

  State step(State state) {
    final instruction = raw[state.programCounter % raw.length];
    final nextNodes = state.currentNodes.map((currentNode) {
      final (left, right) = state.nodes[currentNode]!;
      if (instruction == 'R') {
        return right;
      } else {
        return left;
      }
    });
    return state.nextNodes(nextNodes.toList(growable: false));
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
    var state = State.initialPartOne(nodes);
    while (state.currentNodes[0] != 'ZZZ') {
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
    var state = State.initialPartTwo(nodes);
    print('Starting search with ${state.currentNodes.length} starting nodes');
    while (!state.currentNodes.every((n) => n.endsWith('Z'))) {
      state = program.step(state);
      if (state.programCounter % 10000000 == 0) {
        print('Program counter: ${state.programCounter}');
      }
    }
    return state.programCounter;
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
