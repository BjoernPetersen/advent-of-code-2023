import 'dart:collection';
import 'dart:math';

import 'package:aoc/day.dart';
import 'package:meta/meta.dart';

@immutable
class Card {
  final int id;
  final Set<int> guesses;
  final Set<int> winningNumbers;

  Card({
    required this.id,
    required this.guesses,
    required this.winningNumbers,
  });

  static Set<int> _parseNumbers(String numbers) {
    return numbers
        .split(' ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map(int.parse)
        .toSet();
  }

  factory Card.fromString(String card) {
    final [name, numbers] = card.split(': ');
    final id = name.split(' ').last;
    final [guesses, winningNumbers] = numbers.split(' | ');
    return Card(
      id: int.parse(id),
      guesses: _parseNumbers(guesses),
      winningNumbers: _parseNumbers(winningNumbers),
    );
  }

  int get matchCount => guesses.intersection(winningNumbers).length;

  int determineWorth() {
    final matchCount = this.matchCount;
    return matchCount == 0 ? 0 : pow(2, matchCount - 1) as int;
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) {
    return input
        .map(Card.fromString)
        .map((card) => card.determineWorth())
        .reduce((a, b) => a + b);
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final cards = await input.map(Card.fromString).toList();
    final counts = List.filled(cards.length, 1);

    for (final (index, card) in cards.indexed) {
      final score = card.matchCount;
      for (var wonIndex = index + 1;
          wonIndex < cards.length && (wonIndex - index) <= score;
          wonIndex += 1) {
        counts[wonIndex] += counts[index];
      }
    }

    return counts.reduce((a, b) => a + b);
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
