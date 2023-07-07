import 'dart:async';

import 'package:equatable/equatable.dart';

/// Data structure similar to a nullable type. Most of the time `Optional<T>`
/// can be thought of as `T?` but in some cases null is a valid value
/// and we'd like to additionally describe a lack of such value. The Optional
/// type can be nested, so `Optional<Optional<T>>` is valid, while there is
/// no nullable-nullable T, i.e. `T??`.
///
/// In Optional [Nothing] corresponds to null and [Value] is the present value.
/// Note that [Value] can contain null if `T` is nullable.
sealed class Optional<T> extends Equatable {
  const Optional();

  static Optional<T> fromNullable<T extends Object>(T? value) =>
      value == null ? Nothing<T>() : Value(value);

  T? get value;

  bool get hasValue => switch (this) {
        Value() => true,
        Nothing() => false,
      };

  T unwrap() => switch (this) {
        Value(:final value) => value,
        Nothing() => throw OptionalUnwrapError(),
      };

  @override
  bool? get stringify => true;

  static Optional<T> sequence<T>(T Function() body) {
    try {
      final result = body();
      assert(
        result is! Future,
        'use [asyncSequence] for asynchronous calculations instead',
      );
      return Value(result);
      // ignore: avoid_catching_errors
    } on OptionalUnwrapError {
      return Nothing<T>();
    }
  }

  static Future<Optional<T>> asyncSequence<T>(
    FutureOr<T> Function() body,
  ) async {
    try {
      final result = await body();
      return Value(result);
      // ignore: avoid_catching_errors
    } on OptionalUnwrapError {
      return Nothing<T>();
    }
  }
}

/// [Optional] variant where value is present.
final class Value<T> extends Optional<T> {
  const Value(this.value);

  @override
  final T value;

  @override
  List<Object?> get props => [value];
}

/// [Optional] variant where there is no value.
final class Nothing<T> extends Optional<T> {
  const Nothing();

  @override
  Null get value => null;

  @override
  List<Object?> get props => const [];
}

extension FlattenOptional<T> on Optional<Optional<T>> {
  Optional<T> flatten() => value ?? const Nothing();
}

class OptionalUnwrapError extends Error {}
