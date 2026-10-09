enum Statuses {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == Statuses.initial;
  bool get isLoading => this == Statuses.loading;
  bool get isSuccess => this == Statuses.success;
  bool get isFailure => this == Statuses.failure;
}
