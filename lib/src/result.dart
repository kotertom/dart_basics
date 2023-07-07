import 'dart:async';

import 'package:dart_basics/src/optional.dart';
import 'package:equatable/equatable.dart';

/// Data structure that describes a result of an operation: either it was
/// successful (see [Success]) or it failed (see [Failure]).
sealed class Result<T, E> extends Equatable {
  const Result();

  static Result<T, void> fromOptional<T>(Optional<T> optional) =>
      switch (optional) {
        Value(:final value) => Success(value),
        Nothing() => Failure<T, void>(null),
      };

  Success<T, E>? get asSuccess => switch (this) {
        final Success<T, E> s => s,
        Failure() => null,
      };

  Failure<T, E>? get asFailure => switch (this) {
        Success() => null,
        final Failure<T, E> f => f,
      };

  bool get isSuccess => asSuccess != null;
  bool get isFailure => asFailure != null;

  T? get data => asSuccess?.data;
  E? get error => asFailure?.error;

  @override
  bool? get stringify => true;

  T? get optionalData => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  Optional<E> get optionalError => switch (this) {
        Success() => Nothing<E>(),
        Failure(:final error) => Value(error),
      };

  T unwrap() => switch (this) {
        Success(:final data) => data,
        Failure(:final error) => throw ResultUnwrapError(error),
      };

  Result<E, T> swap() => switch (this) {
        Success(:final data) => Failure(data),
        Failure(:final error) => Success(error),
      };

  static Future<Result<T, ErrorWithStackTrace>> capture<T>(
    FutureOr<T> Function() action,
  ) async {
    try {
      final result = await action();
      return Success(result);
    } catch (e, st) {
      return Failure((e, st));
    }
  }

  static Stream<Result<T, ErrorWithStackTrace>> captureStream<T>(
    Stream<T> stream,
  ) =>
      stream.map<Result<T, ErrorWithStackTrace>>(Success.new).handleError(
            (dynamic e, dynamic st) => Failure<T, ErrorWithStackTrace>((e, st)),
          );

  /// Calling [unwrap] is safe inside the [body] callback.
  static Result<T, Object?> sequence<T>(T Function() body) {
    try {
      final result = body();
      assert(
        result is! Future,
        'use [asyncSequence] for asynchronous calculations instead',
      );
      return Success(result);
      // ignore: avoid_catching_errors
    } on ResultUnwrapError<Object?> catch (e) {
      return Failure(e.inner);
    }
  }

  static Future<Result<T, Object?>> asyncSequence<T>(
    FutureOr<T> Function() body,
  ) async {
    try {
      final result = await body();
      return Success(result);
      // ignore: avoid_catching_errors
    } on ResultUnwrapError<Object?> catch (e) {
      return Failure(e.inner);
    }
  }
}

/// [Result] variant that describes a successful operation with [data].
final class Success<T, E> extends Result<T, E> {
  const Success(this.data);

  @override
  final T data;

  @override
  List<Object?> get props => [data];
}

/// [Result] variant that describes a failed operation with [error].
final class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);

  @override
  final E error;

  @override
  List<Object?> get props => [error];
}

// Initially this was `FutureOr<T>` but this led to global namespace pollution
// (all types are a `FutureOr<T>` and IDE completions would show it
// as a possible method for everything).
extension FutureIntoResult<T> on Future<T> {
  Future<Result<T, ErrorWithStackTrace>> intoResult() =>
      Result.capture(() => this);
}

typedef ErrorWithStackTrace = (Object error, StackTrace stackTrace);

class ResultUnwrapError<E> extends Error {
  ResultUnwrapError(this.inner);

  final E inner;

  @override
  String toString() {
    return 'Unwrapping of result failed: ${Error.safeToString(inner)}';
  }
}
