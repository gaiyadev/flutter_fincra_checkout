# Flutter Fincra Checkout Example

A complete working example demonstrating how to integrate the `flutter_fincra_checkout` package into your Flutter application.

## 🚀 Getting Started

This example app showcases both the **WebView Checkout** and **Inline Checkout** flows. 

### Prerequisites

To test the **Inline Checkout** flow, you must replace the placeholder `publicKey` in `lib/main.dart` with your actual Fincra public key.

```dart
// lib/main.dart
InlineCheckoutConfig(
  publicKey: "pk_test_YOUR_ACTUAL_KEY", // <--- REPLACE THIS
  amount: 5000,
  // ...
)
```

*(Note: For testing the WebView flow, you typically need to generate a checkout session URL from your backend using your Secret Key).*

### Running the Example

1. Ensure you have an emulator or device connected.
2. Run the app:
```bash
flutter run
```

## 💡 What it Demonstrates

- How to construct an `InlineCheckoutConfig`.
- How to trigger `FincraCheckout.openInline()` asynchronously.
- How to handle `FincraCheckoutSuccess`, `FincraCheckoutError`, and `FincraCheckoutCancelled` results using a strongly-typed `switch` statement.
- How to filter `paymentMethods` safely.
