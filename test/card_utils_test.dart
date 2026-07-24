import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fincra_checkout/flutter_fincra_checkout.dart';

void main() {
  group('CardUtils Tests', () {
    test('validateCardNumber returns true for valid test cards', () {
      // 4242424242424242 is a standard test card (Luhn valid)
      expect(CardUtils.validateCardNumber('4242424242424242'), isTrue);
      // Formatted version should also be valid
      expect(CardUtils.validateCardNumber('4242 4242 4242 4242'), isTrue);
    });

    test('validateCardNumber returns false for invalid cards', () {
      expect(CardUtils.validateCardNumber('4242424242424241'), isFalse);
      expect(CardUtils.validateCardNumber('1234567890123456'), isFalse);
      expect(CardUtils.validateCardNumber(''), isFalse);
      expect(CardUtils.validateCardNumber('abcdef'), isFalse);
    });

    test('validateDate returns true for valid future dates', () {
      final now = DateTime.now();
      final futureYear = (now.year + 2) - 2000;
      expect(CardUtils.validateDate('12/$futureYear'), isTrue);
    });

    test('validateDate returns false for past dates and invalid formats', () {
      expect(CardUtils.validateDate('12/10'), isFalse); // Year 2010
      expect(CardUtils.validateDate('13/30'), isFalse); // Month 13
      expect(CardUtils.validateDate('00/30'), isFalse); // Month 0
      expect(CardUtils.validateDate('1230'), isFalse); // Missing slash
      expect(CardUtils.validateDate(''), isFalse);
    });

    test('validateCVV returns correct results', () {
      expect(CardUtils.validateCVV('123'), isTrue);
      expect(CardUtils.validateCVV('1234'), isTrue); // AMEX CVV
      expect(CardUtils.validateCVV('12'), isFalse);
      expect(CardUtils.validateCVV('12345'), isFalse);
      expect(CardUtils.validateCVV('abc'), isFalse);
      expect(CardUtils.validateCVV(''), isFalse);
    });
  });

  group('CardDetails Model Tests', () {
    test('extracts clean card number correctly', () {
      final details = CardDetails(
        cardNumber: '4242 4242 4242 4242',
        cvv: '123',
        expiryMonth: 12,
        expiryYear: 25,
      );
      expect(details.cleanCardNumber, '4242424242424242');
    });

    test('identifies Visa brand correctly', () {
      final details = CardDetails(
        cardNumber: '4242 4242 4242 4242',
        cvv: '123',
        expiryMonth: 12,
        expiryYear: 25,
      );
      expect(details.brand, CardBrand.visa);
    });

    test('identifies Mastercard brand correctly', () {
      final details = CardDetails(
        cardNumber: '5100 0000 0000 0000',
        cvv: '123',
        expiryMonth: 12,
        expiryYear: 25,
      );
      expect(details.brand, CardBrand.mastercard);
    });
  });
}
