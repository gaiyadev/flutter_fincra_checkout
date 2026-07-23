class FincraPaymentError {
  final String code;
  final String message;

  FincraPaymentError({required this.code, required this.message});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FincraPaymentError &&
        other.code == code &&
        other.message == message;
  }

  @override
  int get hashCode => code.hashCode ^ message.hashCode;

  @override
  String toString() {
    return 'FincraPaymentError(code: $code, message: $message)';
  }
}
