import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fincra_checkout/flutter_fincra_checkout.dart';

void main() {
  testWidgets('FincraCheckout.open can be called', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                FincraCheckout.openWebView(
                  context,
                  config: const WebViewCheckoutConfig(
                    checkoutUrl: 'https://checkout.sandbox.fincra.com',
                    appBarTitle: 'Test Checkout',
                  ),
                );
              },
              child: const Text('Open Checkout'),
            );
          },
        ),
      ),
    );

    expect(find.text('Open Checkout'), findsOneWidget);
  });
  test('InlineCheckout is exported from the package barrel', () {
    const widget = InlineCheckout(
      config: InlineCheckoutConfig(
        publicKey: 'pk_test',
        amount: 100,
        currency: FincraCurrency.ngn,
        customerEmail: 'test@test.com',
        customerName: 'Test',
        feeBearer: FeeBearer.customer,
      ),
    );

    expect(widget, isA<StatefulWidget>());
  });
}
