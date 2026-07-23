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
  final Widget? loadingWidget;
  final Widget? closeIcon;
  final bool showCancelConfirmationDialog;

  const CheckoutWebView({
    super.key,
    required this.checkoutUrl,
    this.redirectUrl,
    this.appBarBackgroundColor,
    this.appBarTitle,
    this.loadingWidget,
    this.closeIcon,
    this.showCancelConfirmationDialog = false,
  });

  @override
  State<CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<CheckoutWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasCompleted = false;
  bool _isPopping = false;

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
            if (UrlHandler.isCompletionUrl(
              request.url,
              expectedRedirectUrl: widget.redirectUrl,
            )) {
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
    // If we reached the redirect URL, Fincra might not append the status parameter
    // in sandbox, so we safely assume success if it's missing.
    final status = params['status']?.toLowerCase() ?? 'success';

    if (status == 'success' || status == 'successful') {
      final response = FincraPaymentResponse.fromUrlParams(params);
      Navigator.of(context).pop(FincraCheckoutSuccess(response));
    } else {
      final err = FincraPaymentError(
        code: status,
        message: params['message'] ?? 'Payment failed',
      );
      Navigator.of(context).pop(FincraCheckoutError(err));
    }
  }

  void _handleCancellation() async {
    if (_hasCompleted) return;

    if (widget.showCancelConfirmationDialog) {
      final shouldCancel = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Payment?'),
          content: const Text('Are you sure you want to cancel this payment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (shouldCancel != true || !mounted) {
        return;
      }
    }

    if (!mounted) return;

    _hasCompleted = true;

    if (widget.showCancelConfirmationDialog) {
      setState(() {
        _isPopping = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop(FincraCheckoutCancelled());
        }
      });
    } else {
      Navigator.of(context).pop(FincraCheckoutCancelled());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.showCancelConfirmationDialog ? _isPopping : true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleCancellation();
        } else {
          _hasCompleted = true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarTitle ?? 'Secure Checkout'),
          elevation: 0,
          backgroundColor: widget.appBarBackgroundColor,
          leading: IconButton(
            icon: widget.closeIcon ?? const Icon(Icons.close),
            onPressed: () {
              if (widget.showCancelConfirmationDialog) {
                Navigator.maybePop(context);
              } else {
                _handleCancellation();
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(
                child:
                    widget.loadingWidget ?? const CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
