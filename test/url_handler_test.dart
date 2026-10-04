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
    test('isCompletionUrl rejects lookalike hosts for expectedRedirectUrl', () {
      expect(
        UrlHandler.isCompletionUrl(
          'https://google.com.evil.io/callback?status=success',
          expectedRedirectUrl: 'https://google.com',
        ),
        isFalse,
      );
      expect(
        UrlHandler.isCompletionUrl(
          'https://myapp.com/callbacks-other',
          expectedRedirectUrl: 'https://myapp.com/callback',
        ),
        isFalse,
      );
    });

    test('isCompletionUrl accepts sub-paths and trailing slashes', () {
      expect(
        UrlHandler.isCompletionUrl(
          'https://myapp.com/callback/',
          expectedRedirectUrl: 'https://myapp.com/callback',
        ),
        isTrue,
      );
      expect(
        UrlHandler.isCompletionUrl(
          'https://myapp.com/callback/done?reference=R1',
          expectedRedirectUrl: 'https://myapp.com/callback/',
        ),
        isTrue,
      );
      expect(
        UrlHandler.isCompletionUrl(
          'https://google.com/?status=success',
          expectedRedirectUrl: 'https://google.com',
        ),
        isTrue,
      );
    });

    test('extractStatus prefers status, then payment_status', () {
      expect(UrlHandler.extractStatus({'status': 'SUCCESS'}), 'success');
      expect(UrlHandler.extractStatus({'payment_status': 'failed'}), 'failed');
      expect(
        UrlHandler.extractStatus({
          'status': 'failed',
          'payment_status': 'success',
        }),
        'failed',
      );
      expect(UrlHandler.extractStatus({}), 'success');
    });
  });
}
