import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fincra_checkout/src/models/fincra_response.dart';
import 'package:flutter_fincra_checkout/src/models/fincra_error.dart';
import 'package:flutter_fincra_checkout/src/models/checkout_config.dart';
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

    test('FincraPaymentResponse parses merchantReference fallback correctly', () {
      final params = {
        'reference': 'fcr-p-internal123',
        'merchantReference': 'ORDER-555',
        'status': 'success',
      };

      final response = FincraPaymentResponse.fromUrlParams(params);

      // It should prioritize merchantReference for reference, and fallback to reference for transactionId
      expect(response.reference, 'ORDER-555');
      expect(response.transactionId, 'fcr-p-internal123');
      expect(response.status, 'success');
      expect(response.rawResponse, params);
    });

    test('FincraPaymentError instantiates correctly', () {
      final error = FincraPaymentError(code: '400', message: 'Bad request');

      expect(error.code, '400');
      expect(error.message, 'Bad request');
    });

    test('WebViewCheckoutConfig stores values correctly', () {
      const config = WebViewCheckoutConfig(
        checkoutUrl: 'https://test.com',
        redirectUrl: 'https://redirect.com',
        appBarTitle: 'Title',
      );

      expect(config.checkoutUrl, 'https://test.com');
      expect(config.redirectUrl, 'https://redirect.com');
      expect(config.appBarTitle, 'Title');
    });

    test('InlineCheckoutConfig stores values correctly', () {
      const config = InlineCheckoutConfig(
        publicKey: 'pk_123',
        amount: 100.50,
        currency: FincraCurrency.ngn,
        customerEmail: 'test@test.com',
        customerName: 'Test Name',
        customerPhoneNumber: '0800000000',
        reference: 'REF123',
        paymentMethods: ['card'],
        feeBearer: FeeBearer.business,
      );

      expect(config.publicKey, 'pk_123');
      expect(config.amount, 100.50);
      expect(config.currency, FincraCurrency.ngn);
      expect(config.customerName, 'Test Name');
      expect(config.reference, 'REF123');
      expect(config.paymentMethods, ['card']);
      expect(config.feeBearer, FeeBearer.business);
    });
  });
}
