import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fincra_checkout/src/models/fincra_response.dart';
import 'package:flutter_fincra_checkout/src/models/fincra_error.dart';

void main() {
  group('Fincra Models', () {
    test('FincraPaymentResponse parses from url params correctly', () {
      final params = {
        'reference': 'REF123',
        'transactionId': 'TXN123',
        'status': 'success',
        'message': 'Payment successful',
      };

      final response = FincraPaymentResponse.fromUrlParams(params);

      expect(response.reference, 'REF123');
      expect(response.transactionId, 'TXN123');
      expect(response.status, 'success');
      expect(response.message, 'Payment successful');
      expect(response.rawResponse, params);
    });

    test('FincraPaymentError instantiates correctly', () {
      final error = FincraPaymentError(code: '400', message: 'Bad request');

      expect(error.code, '400');
      expect(error.message, 'Bad request');
    });
  });
}
