import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/fincra_response.dart';
import '../models/fincra_error.dart';
import '../models/fincra_checkout_result.dart';
import '../utils/url_handler.dart';

class CheckoutWebView extends StatefulWidget {
  final String checkoutUrl;
  final String? redirectUrl;
  final Color? appBarBackgroundColor;
  final String? appBarTitle;

  const CheckoutWebView({
    super.key,
    required this.checkoutUrl,
    this.redirectUrl,
    this.appBarBackgroundColor,
    this.appBarTitle,
  });

  @override
  State<CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<CheckoutWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (UrlHandler.isCompletionUrl(request.url, expectedRedirectUrl: widget.redirectUrl)) {
              _handleCompletion(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            if (_hasCompleted) return;
            _hasCompleted = true;
            final err = FincraPaymentError(
              code: error.errorCode.toString(),
              message: error.description,
            );
            Navigator.of(context).pop(FincraCheckoutError(err));
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _handleCompletion(String url) {
    if (_hasCompleted) return;
    _hasCompleted = true;

    final params = UrlHandler.extractResponseParams(url);
    final status = params['status']?.toLowerCase();
    
    if (status == 'success' || status == 'successful') {
      final response = FincraPaymentResponse.fromUrlParams(params);
      Navigator.of(context).pop(FincraCheckoutSuccess(response));
    } else {
      final err = FincraPaymentError(
        code: status ?? 'unknown_error',
        message: params['message'] ?? 'Payment failed',
      );
      Navigator.of(context).pop(FincraCheckoutError(err));
    }
  }

  void _handleCancellation() {
    if (_hasCompleted) return;
    _hasCompleted = true;
    Navigator.of(context).pop(FincraCheckoutCancelled());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        _hasCompleted = true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarTitle ?? 'Secure Checkout'),
          elevation: 0,
          backgroundColor: widget.appBarBackgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleCancellation,
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
