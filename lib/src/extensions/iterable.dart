part of uhst_extensions;

/// Common functions for iterables
extension MapIndexed<E> on Iterable<E> {
  /// url: https://stackoverflow.com/a/61349527/9908821
  Iterable<V> mapIndexed<V>(
    final V Function(int index, E item) transform,
  ) sync* {
    int index = 0;

    for (final item in this) {
      yield transform(index, item);
      index++;
    }
  }

  /// Returns the first element that satisfies the given predicate [test].
  ///
  /// Iterates through elements and returns the first to satisfy [test].
  ///
  /// If no element satisfies [test], the result will be [null]
  E? firstWhereOrNull(final bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
