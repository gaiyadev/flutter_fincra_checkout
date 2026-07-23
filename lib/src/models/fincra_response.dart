class FincraPaymentResponse {
  final String reference;
  final String transactionId;
  final String status;
  final String? message;
  final Map<String, dynamic>? rawResponse;

  FincraPaymentResponse({
    required this.reference,
    required this.transactionId,
    required this.status,
    this.message,
    this.rawResponse,
  });

  factory FincraPaymentResponse.fromUrlParams(Map<String, String> params) {
    return FincraPaymentResponse(
      reference: params['reference'] ?? '',
      transactionId: params['transactionId'] ?? '',
      status: params['status'] ?? 'unknown',
      message: params['message'],
      rawResponse: params,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FincraPaymentResponse &&
        other.reference == reference &&
        other.transactionId == transactionId &&
        other.status == status &&
        other.message == message;
  }

  @override
  int get hashCode {
    return reference.hashCode ^
        transactionId.hashCode ^
        status.hashCode ^
        message.hashCode;
  }

  @override
  String toString() {
    return 'FincraPaymentResponse(reference: $reference, transactionId: $transactionId, status: $status, message: $message)';
  }
}
