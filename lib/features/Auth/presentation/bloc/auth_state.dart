class AuthState {
  bool isLoading;
  bool isSuccess;
  String? errorMessage;
  String? userId;
  AuthState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.userId,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? Function()? errorMessage,
    String? userId,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      userId: userId ?? this.userId,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
