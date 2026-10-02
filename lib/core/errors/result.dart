import 'package:tenant_tracker/core/errors/failure.dart';

sealed class Result<T> {
  const Result();

  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) =>
      switch (this) {
        Ok<T>(:final value) => onSuccess(value),
        Err<T>(:final failure) => onFailure(failure),
      };

  /// Changes the success value; a failure passes through unchanged.
  Result<R> map<R>(R Function(T) transform) => switch (this) {
        Ok<T>(:final value) => Ok(transform(value)),
        Err<T>(:final failure) => Err(failure),
      };

  /// Chains a step that can itself fail; the first failure wins.
  Result<R> flatMap<R>(Result<R> Function(T) next) => switch (this) {
        Ok<T>(:final value) => next(value),
        Err<T>(:final failure) => Err(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
