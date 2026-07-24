import 'package:flutter/material.dart';
import '../models/fincra_response.dart';
import '../models/fincra_error.dart';
import '../models/fincra_checkout_result.dart';
import '../models/checkout_config.dart';
import '../webview/checkout_webview.dart';
import '../inline/inline_checkout.dart';

class FincraCheckout {
  /// Opens the Fincra checkout in a full-screen native WebView.
  ///
  /// This is the recommended flow using a backend-generated checkout URL.
  ///
  /// Returns a [FincraCheckoutResult] which can be awaited for async flows.
  /// Optionally, you can also provide callbacks for [onSuccess], [onFailed], and [onCancelled].
  static Future<FincraCheckoutResult> openWebView(
    BuildContext context, {
    required WebViewCheckoutConfig config,
    ValueChanged<FincraPaymentResponse>? onSuccess,
    ValueChanged<FincraPaymentError>? onFailed,
    VoidCallback? onCancelled,
  }) async {
    final result = await Navigator.of(context).push<FincraCheckoutResult>(
      MaterialPageRoute(
        builder: (context) => CheckoutWebView(
          checkoutUrl: config.checkoutUrl,
          redirectUrl: config.redirectUrl,
          appBarBackgroundColor: config.appBarBackgroundColor,
          appBarTitle: config.appBarTitle,
          loadingWidget: config.loadingWidget,
          closeIcon: config.closeIcon,
          showCancelConfirmationDialog: config.showCancelConfirmationDialog,
        ),
        fullscreenDialog: true,
      ),
    );

    return _handleResult(result, onSuccess, onFailed, onCancelled);
  }

  /// Opens the Fincra inline JavaScript checkout.
  ///
  /// This flow loads the Fincra JavaScript SDK in a secure WebView and handles
  /// communication with your Flutter app automatically.
  ///
  /// Returns a [FincraCheckoutResult] which can be awaited for async flows.
  /// Optionally, you can also provide callbacks for [onSuccess], [onFailed], and [onCancelled].
  static Future<FincraCheckoutResult> openInline(
    BuildContext context, {
    required InlineCheckoutConfig config,
    ValueChanged<FincraPaymentResponse>? onSuccess,
    ValueChanged<FincraPaymentError>? onFailed,
    VoidCallback? onCancelled,
  }) async {
    final result = await Navigator.of(context).push<FincraCheckoutResult>(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return InlineCheckout(config: config);
        },
      ),
    );

    return _handleResult(result, onSuccess, onFailed, onCancelled);
  }

  /// Opens the Fincra checkout in a full-screen WebView.
  ///
  /// Deprecated: Use [openWebView] instead for native WebView checkout flow.
  @Deprecated('Use openWebView instead')
  static Future<FincraCheckoutResult> open(
    BuildContext context, {
    required String checkoutUrl,
    String? redirectUrl,
    Color? appBarBackgroundColor,
    String? appBarTitle,
    Widget? loadingWidget,
    Widget? closeIcon,
    bool showCancelConfirmationDialog = false,
    ValueChanged<FincraPaymentResponse>? onSuccess,
    ValueChanged<FincraPaymentError>? onFailed,
    VoidCallback? onCancelled,
  }) async {
    return openWebView(
      context,
      config: WebViewCheckoutConfig(
        checkoutUrl: checkoutUrl,
        redirectUrl: redirectUrl,
        appBarBackgroundColor: appBarBackgroundColor,
        appBarTitle: appBarTitle,
        loadingWidget: loadingWidget,
        closeIcon: closeIcon,
        showCancelConfirmationDialog: showCancelConfirmationDialog,
      ),
      onSuccess: onSuccess,
      onFailed: onFailed,
      onCancelled: onCancelled,
    );
  }

  static FincraCheckoutResult _handleResult(
    FincraCheckoutResult? result,
    ValueChanged<FincraPaymentResponse>? onSuccess,
    ValueChanged<FincraPaymentError>? onFailed,
    VoidCallback? onCancelled,
  ) {
    final finalResult = result ?? FincraCheckoutCancelled();

    if (finalResult is FincraCheckoutSuccess) {
      onSuccess?.call(finalResult.response);
    } else if (finalResult is FincraCheckoutError) {
      onFailed?.call(finalResult.error);
    } else if (finalResult is FincraCheckoutCancelled) {
      onCancelled?.call();
    }

    return finalResult;
  }
}
