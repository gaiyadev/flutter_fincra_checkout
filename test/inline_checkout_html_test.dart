import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fincra_checkout/flutter_fincra_checkout.dart';
import 'package:flutter_fincra_checkout/src/inline/inline_checkout.dart';

InlineCheckoutConfig _config({String? phone}) => InlineCheckoutConfig(
  publicKey: 'pk_test',
  amount: 100,
  currency: FincraCurrency.ngn,
  customerEmail: 'test@test.com',
  customerName: 'Test',
  customerPhoneNumber: phone,
  feeBearer: FeeBearer.customer,
);

void main() {
  group('buildInlineCheckoutHtml phoneNumber', () {
    test('omits phoneNumber when not provided', () {
      final html = buildInlineCheckoutHtml(_config());

      expect(html, isNot(contains('phoneNumber')));
      expect(html, contains('email: "test@test.com"'));
    });

    test('omits phoneNumber when blank', () {
      final html = buildInlineCheckoutHtml(_config(phone: '   '));

      expect(html, isNot(contains('phoneNumber')));
    });

    test('includes trimmed phoneNumber when provided', () {
      final html = buildInlineCheckoutHtml(_config(phone: ' 08012345678 '));

      expect(html, contains('phoneNumber: "08012345678",'));
    });
  });
}
