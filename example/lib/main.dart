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

  Future<void> _startPayment(BuildContext context) async {
    // In a real app, this URL is obtained from your backend by calling the Fincra API.
    // Ensure that you set a redirectUrl during the Fincra backend API call so that
    // Fincra redirects back with the status parameters appended.
    const mockCheckoutUrl =
        'https://sandbox-checkout.fincra.com/pay/fcr-p-73d48cb535';

    final result = await FincraCheckout.open(
      context,
      checkoutUrl: mockCheckoutUrl,
      redirectUrl: 'https://myapp.com/callback',
      appBarTitle: 'Fincra Payment',
      appBarBackgroundColor: Colors.white,
      closeIcon: const Icon(Icons.arrow_back_ios),
      loadingWidget: const CircularProgressIndicator(color: Colors.redAccent),
      showCancelConfirmationDialog: true,
    );

    if (context.mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fincra SDK Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _startPayment(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('Pay with Fincra', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
