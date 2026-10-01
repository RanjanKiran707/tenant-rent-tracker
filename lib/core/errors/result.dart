import 'package:tenant_tracker/core/errors/failure.dart';

sealed class Result<T> {
  const Result();

  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) =>
      switch (this) {
        Ok<T>(:final value) => onSuccess(value),
        Err<T>(:final failure) => onFailure(failure),
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
