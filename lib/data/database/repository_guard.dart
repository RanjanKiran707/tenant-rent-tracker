import 'dart:async';

import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';

/// Runs [action] and turns any exception into `Err(StorageFailure)`.
/// Used only by repository implementations (the one layer that catches).
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } catch (e) {
    return Err(StorageFailure(e.toString()));
  }
}

/// Wraps a storage stream: values become `Ok`, stream errors become `Err`
/// (the stream keeps running instead of throwing).
Stream<Result<T>> guardStream<T>(Stream<T> source) {
  return source.transform(
    StreamTransformer<T, Result<T>>.fromHandlers(
      handleData: (data, sink) => sink.add(Ok(data)),
      handleError: (error, stackTrace, sink) =>
          sink.add(Err(StorageFailure(error.toString()))),
    ),
  );
}
