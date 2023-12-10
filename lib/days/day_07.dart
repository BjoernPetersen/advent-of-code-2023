import 'package:aoc/day.dart';
import 'package:aoc/days/util.dart';
import 'package:meta/meta.dart';

enum Rules {
  serious('AKQJT98765432'),
  joke('AKQT98765432J'),
  ;

  final String order;

  const Rules(this.order);
}

@immutable
class HandType {
  static final values = [
    HandType(
      name: 'onePair',
      seriousMatcher: RegExp(r'(.)\1').hasMatch,
      jokeMatcher: RegExp(r'(?:(.)\1|J)').hasMatch,
    ),
    HandType(
      name: 'twoPair',
      seriousMatcher: RegExp(r'(.)\1.*(.)\2').hasMatch,
      jokeMatcher: RegExp(r'(?:(.)\1.*(.)\2|(.)\3.*J)').hasMatch,
    ),
    HandType(
      name: 'threeOfAKind',
      seriousMatcher: RegExp(r'(.)\1\1').hasMatch,
      jokeMatcher: RegExp(r'(?:(.)\1\1|(.)\2.*J|JJ)').hasMatch,
    ),
    HandType(
      name: 'fullHouse',
      seriousMatcher: RegExp(r'^(.)\1{1,2}(.)\2{1,2}$').hasMatch,
      jokeMatcher:
          RegExp(r'(?:^(.)\1{1,2}(.)\2{1,2}$|(.)\3(.)\4J|(.)\5\5.*J|(.)\6.*JJ)')
              .hasMatch,
    ),
    HandType(
      name: 'fourOfAKind',
      seriousMatcher: RegExp(r'(.)\1{3}').hasMatch,
      jokeMatcher: RegExp(r'(?:(.)\1{3}|(.)\2{2}.*J|(.)\3.*JJ|JJJ)').hasMatch,
    ),
    HandType(
      name: 'fiveOfAKind',
      seriousMatcher: RegExp(r'(.)\1{4}').hasMatch,
      jokeMatcher:
          RegExp(r'(?:(.)\1{4}|(.)\2{3}J|(.)\3{2}JJ|(.)\4JJJ|J{4,5})').hasMatch,
    ),
  ];

  int get index => values.indexOf(this);
  final String name;
  final Map<Rules, bool Function(String)> _matcher;

  HandType({
    required this.name,
    required bool Function(String) seriousMatcher,
    bool Function(String)? jokeMatcher,
  }) : _matcher = {
          Rules.serious: seriousMatcher,
          Rules.joke: jokeMatcher ?? seriousMatcher,
        };

  bool matches(Rules rules, String sortedHand) {
    return _matcher[rules]!(sortedHand);
  }

  static HandType? findBestMatch(Rules rules, String unsortedHand) {
    final sortedHand = sortHand(unsortedHand, rules: rules);
    return values.reversed
        .where((type) => type.matches(rules, sortedHand))
        .firstOrNull;
  }

  @override
  String toString() {
    return name;
  }
}

String sortHand(String hand, {required Rules rules}) {
  final order = rules.order;
  final chars = hand.chars.toList(growable: false);
  chars.sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b)));
  return chars.join();
}

class Play implements Comparable<Play> {
  final Rules rules;
  final String hand;
  int? _handScore;
  late final HandType? type;
  final int bid;

  Play({
    required this.rules,
    required this.hand,
    required this.bid,
  }) : type = HandType.findBestMatch(rules, hand);

  factory Play.fromString({required String line, required Rules rules}) {
    final [hand, bid] = line.split(' ');
    return Play(
      hand: hand,
      bid: int.parse(bid),
      rules: rules,
    );
  }

  int get handScore {
    final order = rules.order;
    var savedScore = _handScore;
    if (savedScore != null) {
      return savedScore;
    }

    var score = 0;
    for (final char in hand.chars) {
      final charScore = order.length - order.indexOf(char);
      score = score * 100 + charScore;
    }

    _handScore = score;

    return score;
  }

  @override
  int compareTo(Play other) {
    switch ((type, other.type)) {
      case (HandType _, null):
        return 1;
      case (null, HandType _):
        return -1;
      case (final HandType myType, final HandType otherType)
          when myType != otherType:
        return myType.index.compareTo(otherType.index);
      default:
        return handScore.compareTo(other.handScore);
    }
  }

  @override
  String toString() {
    return '$hand $bid ($type)';
  }
}

@immutable
final class PartOne implements IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final plays = await input
        .map((line) => Play.fromString(line: line, rules: Rules.serious))
        .toList();
    plays.sort();
    return plays.indexed.fold<int>(
      0,
      (sum, indexedPlay) {
        final (index, play) = indexedPlay;
        final rank = index + 1;
        return sum + (rank * play.bid);
      },
    );
  }
}

@immutable
final class PartTwo implements IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final plays = await input
        .map((line) => Play.fromString(line: line, rules: Rules.joke))
        .toList();
    plays.sort();
    return plays.indexed.fold<int>(
      0,
      (sum, indexedPlay) {
        final (index, play) = indexedPlay;
        final rank = index + 1;
        return sum + (rank * play.bid);
      },
    );
  }
}

const day = Day(
  PartOne(),
  PartTwo(),
);
