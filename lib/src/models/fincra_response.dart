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
  String toString() {
    return 'FincraPaymentResponse(reference: $reference, transactionId: $transactionId, status: $status, message: $message)';
  }
}
