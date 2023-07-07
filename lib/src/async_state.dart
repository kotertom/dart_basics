import 'dart:async';

import 'package:dart_basics/src/result.dart';
import 'package:equatable/equatable.dart';

/// Describes the state of a long-running operation. It can either be
/// [InProgress] or [Completed]. There is no notion of an unstarted operation,
/// so there is no "idle" or "initial" state.
sealed class AsyncState<T> extends Equatable {
  const AsyncState();

  static Stream<AsyncState<T>> capture<T>(
    FutureOr<T> Function() computation,
  ) async* {
    yield InProgress<T>();
    final result = await computation();
    yield Completed(result);
  }

  static Stream<AsyncState<Result<T, ErrorWithStackTrace>>> captureResult<T>(
    FutureOr<T> Function() computation,
  ) =>
      capture(() => Result.capture(computation));
}

/// Means that the operation is in progress.
final class InProgress<T> extends AsyncState<T> {
  const InProgress();

  @override
  List<Object?> get props => const [];
}

/// Means that the operation completed with [result].
final class Completed<T> extends AsyncState<T> {
  const Completed(this.result);

  final T result;

  @override
  List<Object?> get props => [result];
}
