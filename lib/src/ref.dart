final class Ref<T> implements ReadonlyRef<T> {
  Ref(this.value);

  @override
  T value;

  ReadonlyRef<T> toReadonly() => ReadonlyRef(value);
}

final class ReadonlyRef<T> {
  const ReadonlyRef(this.value);

  final T value;
}
