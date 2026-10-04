// End-to-end checks against the real Fincra sandbox. Requires network and keys:
//
//   flutter test integration_test --dart-define-from-file=.env.json
//
// .env.json (gitignored) holds FINCRA_PUBLIC_KEY and FINCRA_CHECKOUT_URL
// (a fresh hosted link created server-side with your secret key).
import 'package:flutter/material.dart';
import 'package:flutter_fincra_checkout/flutter_fincra_checkout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _publicKey = String.fromEnvironment('FINCRA_PUBLIC_KEY');
const _checkoutUrl = String.fromEnvironment('FINCRA_CHECKOUT_URL');

/// Opens a checkout from a button and records the result it returns.
class _Harness extends StatelessWidget {
  const _Harness({required this.open, required this.onResult});

  final Future<FincraCheckoutResult> Function(BuildContext) open;
  final ValueChanged<FincraCheckoutResult> onResult;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async => onResult(await open(context)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pumps frames until [condition] holds or [timeout] passes.
Future<bool> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 25),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (condition()) return true;
  }
  return condition();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WebView: real hosted checkout loads, cancel returns Cancelled', (
    tester,
  ) async {
    expect(_checkoutUrl, isNotEmpty, reason: 'FINCRA_CHECKOUT_URL not set');
    FincraCheckoutResult? result;

    await tester.pumpWidget(
      _Harness(
        onResult: (r) => result = r,
        open: (context) => FincraCheckout.openWebView(
          context,
          config: const WebViewCheckoutConfig(
            checkoutUrl: _checkoutUrl,
            redirectUrl: 'https://example.com/fincra-callback',
            showCancelConfirmationDialog: true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));

    // The page (and its sub-resources) must finish loading without the SDK
    // treating any resource error as a failed payment.
    final loaded = await _pumpUntil(
      tester,
      () => find.byType(CircularProgressIndicator).evaluate().isEmpty,
    );
    expect(loaded, isTrue, reason: 'checkout page never finished loading');
    await _pumpUntil(tester, () => false, timeout: const Duration(seconds: 5));
    expect(result, isNull, reason: 'checkout closed early with $result');

    // Close -> confirmation dialog -> Yes.
    await tester.tap(find.byIcon(Icons.close));
    await _pumpUntil(tester, () => find.text('Yes').evaluate().isNotEmpty);
    await tester.tap(find.text('Yes'));
    await _pumpUntil(tester, () => result != null);

    expect(result, isA<FincraCheckoutCancelled>());
  });

  testWidgets(
    'Inline: SDK loads without a phone number, back returns Cancelled',
    (tester) async {
      expect(_publicKey, isNotEmpty, reason: 'FINCRA_PUBLIC_KEY not set');
      FincraCheckoutResult? result;

      await tester.pumpWidget(
        _Harness(
          onResult: (r) => result = r,
          open: (context) => FincraCheckout.openInline(
            context,
            config: InlineCheckoutConfig(
              publicKey: _publicKey,
              amount: 500,
              currency: FincraCurrency.ngn,
              customerEmail: 'sdk-test@example.com',
              customerName: 'SDK Test',
              reference: 'SDK-IN-${DateTime.now().millisecondsSinceEpoch}',
              feeBearer: FeeBearer.customer,
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));

      // "ready" from the JS bridge hides the loader; a timeout or SDK error
      // would instead pop a FincraCheckoutError.
      final ready = await _pumpUntil(
        tester,
        () =>
            result != null ||
            find.byType(CircularProgressIndicator).evaluate().isEmpty,
      );
      expect(ready, isTrue, reason: 'inline SDK never became ready');
      await _pumpUntil(
        tester,
        () => false,
        timeout: const Duration(seconds: 5),
      );
      expect(
        result,
        isNull,
        reason: 'inline checkout closed early with $result',
      );

      // System back closes the route exactly once.
      await tester.binding.handlePopRoute();
      await _pumpUntil(tester, () => result != null);

      expect(result, isA<FincraCheckoutCancelled>());
      expect(find.text('open'), findsOneWidget);
    },
  );
}
