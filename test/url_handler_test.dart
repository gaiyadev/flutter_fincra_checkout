import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fincra_checkout/src/utils/url_handler.dart';

void main() {
  group('UrlHandler', () {
    test(
      'isCompletionUrl returns true when status and reference are present',
      () {
        final url =
            'https://myapp.com/callback?status=success&reference=REF123';
        expect(UrlHandler.isCompletionUrl(url), isTrue);
      },
    );

    test('isCompletionUrl returns false when missing parameters', () {
      final url1 = 'https://myapp.com/callback?status=success';
      final url2 = 'https://myapp.com/callback?reference=REF123';
      final url3 = 'https://myapp.com/callback';

      expect(UrlHandler.isCompletionUrl(url1), isFalse);
      expect(UrlHandler.isCompletionUrl(url2), isFalse);
      expect(UrlHandler.isCompletionUrl(url3), isFalse);
    });

    test('isCompletionUrl checks expectedRedirectUrl if provided', () {
      final url = 'https://myapp.com/callback?status=success';
      expect(
        UrlHandler.isCompletionUrl(
          url,
          expectedRedirectUrl: 'https://myapp.com/callback',
        ),
        isTrue,
      );
      expect(
        UrlHandler.isCompletionUrl(
          url,
          expectedRedirectUrl: 'https://otherapp.com/callback',
        ),
        isFalse,
      );
    });

    test('extractResponseParams extracts correctly', () {
      final url =
          'https://myapp.com/callback?status=failed&reference=REF123&message=Insufficient+funds';
      final params = UrlHandler.extractResponseParams(url);

      expect(params['status'], 'failed');
      expect(params['reference'], 'REF123');
      expect(params['message'], 'Insufficient funds');
    });
  });
}
