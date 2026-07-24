## 0.1.0

* **New Feature**: Added support for Fincra Inline JavaScript Checkout.
* **New API**: Introduced `FincraCheckout.openWebView` and `FincraCheckout.openInline`.
* **Deprecation**: `FincraCheckout.open` is now deprecated in favor of `openWebView`.
* Maintains 100% backward compatibility for existing users.

## 0.0.5

* Updated example app to reflect the latest API changes (removed deprecated callbacks).

## 0.0.4

* Major DevRel review and documentation overhaul.
* Added detailed `Customization Parameters` section outlining all callbacks (e.g., `onCancelled`, `onSuccess`) and UI configurations.
* Split usage examples into Async/Await and Callbacks for clearer developer integration.
* Added backend setup examples (using cURL) for generating checkout sessions.

## 0.0.3

* Refined package description for improved SEO and clarity.

## 0.0.2

* Added search keywords (topics) to `pubspec.yaml` for better discoverability.

## 0.0.1

* Initial release.
* Provides `FincraCheckout.open` for seamless in-app Fincra payment integration.
* Fully supports modern `async/await` flows and callback APIs.
* Built-in URL interception for `FincraPaymentResponse` extraction.
