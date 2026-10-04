## 0.1.1

* **Fix**: `InlineCheckout` is now exported from the package, as documented.
* **Fix**: WebView checkout no longer aborts when a sub-resource (image, script, analytics) fails to load; only main-frame errors end the session.
* **Fix**: A completion URL with `payment_status=failed` is now reported as an error instead of a success.
* **Fix**: `redirectUrl` matching now compares scheme, host and path, so lookalike hosts (e.g. `example.com.evil.io`) no longer count as completion.
* **Fix**: Inline checkout errors now carry the real message (e.g. "Fincra SDK failed to load.") instead of a generic one.
* **Fix**: An inline `success` event without data is now reported as success, not cancellation.
* **Fix**: Nested values in inline success data are JSON-encoded in `rawResponse`, and null values are dropped.
* **Fix**: Guarded WebView callbacks against firing after dispose, and prevented a double pop after a system-back on inline checkout.
* **Fix**: `customerPhoneNumber` is now truly optional for inline checkout. When it's null or blank, `phoneNumber` is left out of the Fincra request instead of being sent as `null` or `""`; when present, it is trimmed.
* **Docs**: Corrected install version and `InlineCheckoutConfig` parameter types; added a note on verifying payments server-side.

## 0.1.0

* **New Feature**: Added support for Fincra Inline JavaScript Checkout.
* **New API**: Introduced `FincraCheckout.openWebView` and `FincraCheckout.openInline`.
* **Enhancement**: Added `paymentMethods` array parameter to strictly filter allowed methods (e.g., `["bank_transfer"]`).
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
