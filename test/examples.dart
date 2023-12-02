import 'dart:io';

import 'package:aoc/input.dart';

InputReader getExampleReader(int dayNum, String name) {
  final file = File('examples/${dayNum.toString().padLeft(2, '0')}/$name.txt');
  return InputReader(file);
}
