class StateBloc<T> {
  final T? data;
  final bool isLoading;
  final Object? hasError;

  const StateBloc({this.data, this.isLoading = false, this.hasError});

  StateBloc<T> copyWith({T? data, bool? isLoading, Object? hasError}) {
    return StateBloc(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError,
    );
  }
}
