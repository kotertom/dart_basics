import 'package:equatable/equatable.dart';

base class Newtype<T> extends Equatable {
  const Newtype(this.value);

  final T value;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [value];
}
