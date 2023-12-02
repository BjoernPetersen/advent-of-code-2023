import 'dart:io';

final class InputReader {
  final File path;

  InputReader(this.path);

  Stream<String> readLines() async* {
    if (!path.existsSync()) {
      throw FileSystemException('Input file not found', path.path);
    }

    for (final line in path.readAsLinesSync()) {
      yield line;
    }
  }
}
