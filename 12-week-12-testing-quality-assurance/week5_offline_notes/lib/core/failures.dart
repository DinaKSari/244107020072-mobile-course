sealed class Failure {
  const Failure(this.message);
  final String message;
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

typedef Result<T> = ({T? data, Failure? failure});

extension ResultX<T> on Result<T> {
  /// Mengembalikan data atau melempar Failure (dipakai di provider).
  T get orThrow => failure != null ? throw failure! : data as T;
}