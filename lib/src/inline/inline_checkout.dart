import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/checkout_config.dart';
import '../models/fincra_checkout_result.dart';
import '../models/fincra_error.dart';
import 'javascript_bridge.dart';

class InlineCheckout extends StatefulWidget {
  final InlineCheckoutConfig config;

  const InlineCheckout({super.key, required this.config});

  @override
  State<InlineCheckout> createState() => _InlineCheckoutState();
}

class _InlineCheckoutState extends State<InlineCheckout> {
  late final WebViewController _controller;
  bool _hasCompleted = false;
  bool _isLoading = true;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (_isLoading && mounted) {
        _hasCompleted = true;
        Navigator.of(context).pop(FincraCheckoutError(
          FincraPaymentError(
            code: 'timeout',
            message: 'Fincra Checkout failed to load. Please check your internet connection.',
          ),
        ));
      }
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        fincraJavascriptChannelName,
        onMessageReceived: _handleJavascriptMessage,
      )
      ..loadHtmlString(_generateHtml(widget.config));
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _handleJavascriptMessage(JavaScriptMessage message) {
    if (_hasCompleted) return;

    final parsedMessage = FincraBridgeMessage.fromJsonString(message.message);

    switch (parsedMessage.event) {
      case FincraBridgeEvent.ready:
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        break;
      case FincraBridgeEvent.success:
        _hasCompleted = true;
        if (parsedMessage.data != null) {
          Navigator.of(context).pop(FincraCheckoutSuccess(parsedMessage.data!));
        } else {
          Navigator.of(context).pop(FincraCheckoutCancelled());
        }
        break;
      case FincraBridgeEvent.closed:
        _hasCompleted = true;
        Navigator.of(context).pop(FincraCheckoutCancelled());
        break;
      case FincraBridgeEvent.error:
        _hasCompleted = true;
        final message = parsedMessage.data?.message ?? 'An unknown error occurred';
        Navigator.of(context).pop(FincraCheckoutError(
          FincraPaymentError(code: 'error', message: message),
        ));
        break;
      case FincraBridgeEvent.unknown:
        // Ignore unknown events
        break;
    }
  }

  String _generateHtml(InlineCheckoutConfig config) {
    // Safely encode inputs as JSON strings to avoid injection issues
    final key = jsonEncode(config.publicKey);
    final amount = config.amount;
    final currency = jsonEncode(config.currency);
    final name = jsonEncode(config.customerName);
    final email = jsonEncode(config.customerEmail);
    final phone = jsonEncode(config.customerPhoneNumber);
    final reference = config.reference != null ? jsonEncode(config.reference) : 'null';
    final feeBearer = config.feeBearer != null ? jsonEncode(config.feeBearer!.name) : 'null';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <script src="https://unpkg.com/@fincra-engineering/checkout@2.2.0/dist/inline.min.js"></script>
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: transparent;
    }
  </style>
</head>
<body>
  <script>
    function postMessageToFlutter(event, data) {
      if (window.$fincraJavascriptChannelName) {
        window.$fincraJavascriptChannelName.postMessage(JSON.stringify({ event: event, data: data }));
      }
    }

    function initFincra(attempts = 0) {
      if (typeof Fincra === 'undefined') {
        if (attempts > 150) {
          postMessageToFlutter('error', { message: 'Fincra SDK failed to load.' });
          return;
        }
        setTimeout(function() { initFincra(attempts + 1); }, 100);
        return;
      }
      
      postMessageToFlutter('ready', null);
      
      var options = {
        key: $key,
        amount: $amount,
        currency: $currency,
        customer: {
          name: $name,
          email: $email,
          phoneNumber: $phone,
        },
        onClose: function () {
          postMessageToFlutter('closed', null);
        },
        onSuccess: function (data) {
          postMessageToFlutter('success', data);
        }
      };

      if ($reference !== null) {
        options.reference = $reference;
      }

      if ($feeBearer !== null) {
        options.feeBearer = $feeBearer;
      }

      Fincra.initialize(options);
    }

    window.onload = initFincra;
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: const CircularProgressIndicator(),
                ),
              ),
            if (_isLoading)
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    if (!_hasCompleted) {
                      _hasCompleted = true;
                      Navigator.of(context).pop(FincraCheckoutCancelled());
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
