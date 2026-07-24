import 'package:flutter/material.dart';
import 'package:flutter_fincra_checkout/flutter_fincra_checkout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fincra Checkout Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CheckoutExamplePage(),
    );
  }
}

class CheckoutExamplePage extends StatelessWidget {
  const CheckoutExamplePage({super.key});

  Future<void> _startWebViewPayment(BuildContext context) async {
    // In a real app, this URL is obtained from your backend by calling the Fincra API.
    // Ensure that you set a redirectUrl during the Fincra backend API call so that
    // using your Fincra Secret Key. For testing, paste a generated URL here.
    const mockCheckoutUrl =
        'https://sandbox-checkout.fincra.com/pay/fcr-p-03b459293a';

    final result = await FincraCheckout.openWebView(
      context,
      config: const WebViewCheckoutConfig(
        checkoutUrl: mockCheckoutUrl,
        redirectUrl: 'https://google.com',
        appBarTitle: 'Pay with Fincra',
        appBarBackgroundColor: Colors.white,
        closeIcon: Icon(Icons.arrow_back_ios),
        loadingWidget: CircularProgressIndicator(color: Colors.redAccent),
        showCancelConfirmationDialog: true,
      ),
    );

    if (context.mounted) _handleResult(context, result);
  }

  Future<void> _startInlinePayment(BuildContext context) async {
    final result = await FincraCheckout.openInline(
      context,
      config: InlineCheckoutConfig(
        publicKey:
            "pk_test_NmE2MjM2NTcxMGVmY2RkMWRjNTAzY2ZlOjoxNDA4NTk=", // Replace with your Fincra public key
        amount: 5000,
        currency: FincraCurrency.ngn,
        customerEmail: "customer@example.com",
        customerName: "John Doe",
        customerPhoneNumber: "07058149795",
        reference: 'ORDER-${DateTime.now().millisecondsSinceEpoch}',
        feeBearer: FeeBearer.customer,
        paymentMethods: ["bank_transfer", "card", "payAttitude"],
      ),
    );

    if (context.mounted) _handleResult(context, result);
  }

  void _handleResult(BuildContext context, FincraCheckoutResult result) {
    switch (result) {
      case FincraCheckoutSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment Successful! Ref: ${result.response.reference}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case FincraCheckoutError():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Failed: ${result.error.message}'),
            backgroundColor: Colors.red,
          ),
        );
        break;
      case FincraCheckoutCancelled():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Cancelled by User'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fincra SDK Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _startWebViewPayment(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Pay with WebView Checkout',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startInlinePayment(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Pay with Inline Checkout',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
