/// Represents the status of an API request
enum Status {
  loading,
  success,
  error,
  idle,
}

/// Wrapper class for API responses
class Result<T> {
  final Status status;
  final T? data;
  final String? message;
  final dynamic error;

  Result({
    required this.status,
    this.data,
    this.message,
    this.error,
  });

  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;
  bool get isIdle => status == Status.idle;

  static Result<T> loading<T>() => Result<T>(status: Status.loading);
  static Result<T> success<T>(T data, {String? message}) =>
      Result<T>(status: Status.success, data: data, message: message);
  static Result<T> failure<T>(String message, {dynamic error}) =>
      Result<T>(status: Status.error, message: message, error: error);
  static Result<T> idle<T>() => Result<T>(status: Status.idle);
}

