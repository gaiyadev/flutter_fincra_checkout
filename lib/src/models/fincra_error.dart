class FincraPaymentError {
  final String code;
  final String message;

  FincraPaymentError({
    required this.code,
    required this.message,
  });

  @override
  String toString() {
    return 'FincraPaymentError(code: $code, message: $message)';
  }
}
