# Flutter Fincra Checkout

[![pub package](https://img.shields.io/pub/v/flutter_fincra_checkout.svg)](https://pub.dev/packages/flutter_fincra_checkout)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A production-ready Flutter package that provides a clean, secure, and highly customizable integration for [Fincra Checkout](https://fincra.com/checkout) payments using an in-app WebView.

---

## 🔒 Important Note on Security

**DO NOT** store your Fincra secret keys inside your Flutter application. This SDK is designed to handle only the mobile frontend checkout experience. The actual payment session must be created securely from your backend server.

## ✨ Features

- 📱 **Two Checkout Modes**: Native WebView or Inline JavaScript Checkout.
- 🔗 **Automatic detection** of payment completion URL changes.
- 🎨 **Highly customizable** UI (AppBar, colors, loaders, close icons).
- 🛡️ **Built-in dialogs** to prevent accidental user cancellation.
- ⚡ **Dual integration APIs** (Supports both `async/await` and traditional Callbacks).
- 🐛 **Built-in error handling** for seamless debugging.

## 📦 Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_fincra_checkout: ^1.0.0
```

## 🛠️ Setup

### Android

Ensure your `minSdkVersion` in `android/app/build.gradle` is at least **19** (WebView requirements). Also, add internet permissions in your `AndroidManifest.xml` if not already present:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS

No additional configuration is required for recent versions of Flutter. 

*(Note: If you are using an extremely old Flutter version < 1.22, you may need to opt-in to embedded views in your `Info.plist`)*.

---

## 🚀 Usage

The SDK now supports two separate checkout modes: **WebView Checkout** and **Inline Checkout**.

### Checkout Modes

| Feature | WebView | Inline |
| :--- | :--- | :--- |
| Custom reference | Yes | Yes |
| Backend required | Recommended | Depends |
| Secret key in app | No | No |
| Native experience | Yes | Yes |

---

### 1. WebView Checkout (Recommended)

This is the standard and recommended production flow where the payment session is created on your backend using your **Secret Key**.

#### Step 1: Create a Payment Session (Backend)

Your backend should securely communicate with the Fincra API to initiate a checkout session and return the `checkoutUrl`.

#### Step 2: Open WebView Checkout (Flutter)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_fincra_checkout/flutter_fincra_checkout.dart';

Future<void> _startWebViewPayment(BuildContext context) async {
  final result = await FincraCheckout.openWebView(
    context,
    config: WebViewCheckoutConfig(
      checkoutUrl: "https://checkout.fincra.com/pay/...",
      redirectUrl: "https://your-backend.com/webhook", // Optional
      appBarTitle: "Complete Payment",
      appBarBackgroundColor: Colors.white,
      showCancelConfirmationDialog: true,
    ),
  );
  
  if (!context.mounted) return;
  _handleResult(result);
}
```

---

### 2. Inline JavaScript Checkout

The inline checkout flow allows you to trigger a payment directly from the app using your **Public Key**. Do NOT use your Secret Key here.

#### Open Inline Checkout (Flutter)

```dart
Future<void> _startInlinePayment(BuildContext context) async {
  final result = await FincraCheckout.openInline(
    context,
    config: const InlineCheckoutConfig(
      publicKey: "pk_...", // ONLY use your Fincra PUBLIC key
      amount: 1500,
      currency: FincraCurrency.ngn,
      customerEmail: "customer@example.com",
      customerName: "John Doe",
      customerPhoneNumber: "08012345678",
      reference: "CUSTOM-REF-123", // Optional
    ),
  );
  
  if (!context.mounted) return;
  _handleResult(result);
}
```

---

### Result Handling

Both checkout modes return the same `FincraCheckoutResult` type, allowing you to use a single result handler:

```dart
void _handleResult(FincraCheckoutResult result) {
  switch (result) {
    case FincraCheckoutSuccess():
      print("Success! Reference: ${result.response.reference}");
      break;
    case FincraCheckoutError():
      print("Failed: ${result.error.message}");
      break;
    case FincraCheckoutCancelled():
      print("User cancelled");
      break;
  }
}
```

### Advanced: Custom Layout

If you want full control over the layout (e.g., embedding the checkout in a Bottom Sheet or a specific container instead of a full screen), you can use the raw widgets directly.

#### For WebView:
```dart
CheckoutWebView(
  config: const WebViewCheckoutConfig(
    checkoutUrl: "https://checkout.fincra.com/...",
    redirectUrl: "https://your-backend.com/webhook",
    appBarTitle: "Secure Payment",
  ),
)
```

#### For Inline:
```dart
InlineCheckout(
  config: const InlineCheckoutConfig(
    publicKey: "pk_...",
    amount: 1500,
    currency: FincraCurrency.ngn,
    customerEmail: "customer@example.com",
    customerName: "John Doe",
    customerPhoneNumber: "08012345678",
  ),
)
```

### Configuration Parameters

The configurations for both modes accept various parameters to help you tailor the checkout experience.

#### `WebViewCheckoutConfig`
| Parameter | Type | Description |
| :--- | :--- | :--- |
| `checkoutUrl` | `String` | **(Required)** The generated payment URL from your backend. |
| `redirectUrl` | `String?` | The callback URL your backend sent to Fincra. Used to securely intercept the completion page before Fincra redirects back. |
| `appBarTitle` | `String?` | Sets a custom title for the WebView's AppBar. |
| `appBarBackgroundColor` | `Color?` | Customizes the background color of the AppBar to match your app's theme. |
| `closeIcon` | `Widget?` | Replaces the default exit button (e.g., `Icon(Icons.close)`). |
| `loadingWidget` | `Widget?` | A custom loading indicator displayed while the payment page is initially loading. |
| `showCancelConfirmationDialog` | `bool` | Set to `true` to show a confirmation dialog when the user tries to exit the checkout prematurely. Defaults to `false`. |

#### `InlineCheckoutConfig`
| Parameter | Type | Description |
| :--- | :--- | :--- |
| `publicKey` | `String` | **(Required)** Your Fincra public key. |
| `amount` | `num` | **(Required)** The transaction amount. |
| `currency` | `FincraCurrency` | **(Required)** The currency code enum (e.g., `FincraCurrency.ngn`). |
| `customerEmail` | `String` | **(Required)** The customer's email. |
| `customerName` | `String` | **(Required)** The customer's full name. |
| `customerPhoneNumber` | `String` | **(Required)** The customer's phone number. |
| `feeBearer` | `FeeBearer` | **(Required)** Determines who pays the fees (`FeeBearer.business` or `FeeBearer.customer`). |
| `reference` | `String?` | Optional custom transaction reference. |

*Note: Both `FincraCheckout.openWebView` and `FincraCheckout.openInline` also accept optional `onSuccess`, `onFailed`, and `onCancelled` callbacks if you prefer that over `async/await`.*

---

## 📚 Models

### `FincraPaymentResponse`

| Property | Type | Description |
| :--- | :--- | :--- |
| `reference` | `String` | The unique transaction reference. |
| `transactionId` | `String` | Fincra's internal transaction ID. |
| `status` | `String` | The status of the transaction (e.g., 'success'). |
| `message` | `String?` | Optional message from Fincra. |
| `rawResponse` | `Map` | The raw parameters extracted from the completion URL. |

### `FincraPaymentError`

| Property | Type | Description |
| :--- | :--- | :--- |
| `code` | `String` | The error code or status. |
| `message` | `String` | A description of the error. |

## 💡 Example

Check out the `example/` directory for a complete working application demonstrating the payment flow.
