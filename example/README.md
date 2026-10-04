# Flutter Fincra Checkout Example

A complete working example demonstrating how to integrate the `flutter_fincra_checkout` package into your Flutter application.

## 🚀 Getting Started

This example app showcases both the **WebView Checkout** and **Inline Checkout** flows. 

### Prerequisites

The app reads your keys from `--dart-define` values, so nothing secret lives in source.
Create `example/.env.json` (it is gitignored):

```json
{
  "FINCRA_PUBLIC_KEY": "pk_test_...",
  "FINCRA_CHECKOUT_URL": "https://sandbox-checkout.fincra.com/pay/fcr-p-...",
  "FINCRA_REDIRECT_URL": "https://example.com/fincra-callback"
}
```

- `FINCRA_PUBLIC_KEY`: your Fincra **public** key (used by Inline Checkout). Never put your secret key in an app.
- `FINCRA_CHECKOUT_URL`: a hosted link for WebView Checkout. Create it server-side with your **secret** key, e.g.:

```bash
curl -X POST https://sandboxapi.fincra.com/checkout/payments \
  -H "api-key: $FINCRA_SECRET_KEY" -H "x-pub-key: $FINCRA_PUBLIC_KEY" \
  -H "content-type: application/json" \
  -d '{"amount":500,"currency":"NGN","customer":{"name":"Test","email":"test@example.com"},"redirectUrl":"https://example.com/fincra-callback"}'
```

- `FINCRA_REDIRECT_URL`: the same `redirectUrl` you sent to Fincra.

### Running the Example

1. Ensure you have an emulator or device connected.
2. Run the app:
```bash
flutter run --dart-define-from-file=.env.json
```

### Sandbox integration tests

`integration_test/` drives both flows against the real Fincra sandbox (needs network and the `.env.json` above, with a fresh `FINCRA_CHECKOUT_URL`):

```bash
flutter test integration_test --dart-define-from-file=.env.json
```

## 💡 What it Demonstrates

- How to construct an `InlineCheckoutConfig`.
- How to trigger `FincraCheckout.openInline()` asynchronously.
- How to handle `FincraCheckoutSuccess`, `FincraCheckoutError`, and `FincraCheckoutCancelled` results using a strongly-typed `switch` statement.
- How to filter `paymentMethods` safely.
