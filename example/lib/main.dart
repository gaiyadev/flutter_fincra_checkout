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

  void _startNativePayment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FincraNativeCheckout(
            amountText: 'Pay NGN 5,000',
            headerWidget: const Column(
              children: [
                Icon(Icons.payment, size: 48, color: Colors.blue),
                SizedBox(height: 8),
                Text(
                  'Secure Card Payment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            onPay: (details) async {
              // Simulate backend processing delay
              await Future.delayed(const Duration(seconds: 2));

              if (context.mounted) {
                Navigator.pop(context); // Close bottom sheet

                final last4 = details.cardNumber.length >= 4
                    ? details.cardNumber.substring(
                        details.cardNumber.length - 4,
                      )
                    : details.cardNumber;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Successfully processed ${details.brand.name} ending in $last4',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        );
      },
    );
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
              onPressed: () => _startPayment(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Pay with WebView',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _startNativePayment(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Native UI Checkout',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
