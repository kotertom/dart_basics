extension MapValue<T> on T {
  R map<R>(R Function(T value) fn) => fn(this);
}

void toVoid(Object? _) {}

extension ToVoid on Object? {
  void toVoid() {}
}
