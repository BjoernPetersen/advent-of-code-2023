extension CharIterable on String {
  Iterable<String> get chars sync* {
    for (var i = 0; i < length; i += 1) {
      yield this[i];
    }
  }
}
