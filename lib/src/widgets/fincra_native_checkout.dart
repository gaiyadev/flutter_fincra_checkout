import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/card_details.dart';
import '../utils/card_utils.dart';

/// Configuration for localization strings used in [FincraNativeCheckout].
class FincraCheckoutStrings {
  final String cardNumberLabel;
  final String expiryLabel;
  final String cvvLabel;
  final String requiredError;
  final String invalidCardError;
  final String invalidDateError;
  final String invalidCvvError;

  const FincraCheckoutStrings({
    this.cardNumberLabel = 'Card Number',
    this.expiryLabel = 'MM/YY',
    this.cvvLabel = 'CVV',
    this.requiredError = 'Required',
    this.invalidCardError = 'Invalid card number',
    this.invalidDateError = 'Invalid date',
    this.invalidCvvError = 'Invalid CVV',
  });
}

/// A native checkout widget for collecting credit card details securely.
/// 
/// This widget provides form validation, input formatting, and a customizable UI.
/// When the user taps Pay and the form is valid, the [onPay] callback is triggered
/// with the [CardDetails].
class FincraNativeCheckout extends StatefulWidget {
  final Future<void> Function(CardDetails) onPay;
  final String amountText;
  final InputDecoration? decoration;
  final ButtonStyle? buttonStyle;
  final Widget? headerWidget;
  final FincraCheckoutStrings strings;

  const FincraNativeCheckout({
    super.key,
    required this.onPay,
    required this.amountText,
    this.decoration,
    this.buttonStyle,
    this.headerWidget,
    this.strings = const FincraCheckoutStrings(),
  });

  @override
  State<FincraNativeCheckout> createState() => _FincraNativeCheckoutState();
}

class _FincraNativeCheckoutState extends State<FincraNativeCheckout> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isLoading = false;

  InputDecoration _getDefaultDecoration(String label) {
    return widget.decoration?.copyWith(labelText: label) ??
        InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final expiryParts = _expiryController.text.split('/');
      final month = int.parse(expiryParts[0]);
      final year = int.parse(expiryParts[1]);

      final details = CardDetails(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cvv: _cvvController.text,
        expiryMonth: month,
        expiryYear: year,
      );

      try {
        await widget.onPay(details);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.headerWidget != null) ...[
                widget.headerWidget!,
                const SizedBox(height: 24),
              ],
              TextFormField(
                controller: _cardNumberController,
                decoration: _getDefaultDecoration(widget.strings.cardNumberLabel),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CardNumberInputFormatter(),
                  LengthLimitingTextInputFormatter(23), // Max 19 digits + 4 spaces
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.strings.requiredError;
                  }
                  if (!CardUtils.validateCardNumber(value)) {
                    return widget.strings.invalidCardError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: _getDefaultDecoration(widget.strings.expiryLabel),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ExpiryDateInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return widget.strings.requiredError;
                        }
                        if (!CardUtils.validateDate(value)) {
                          return widget.strings.invalidDateError;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: _getDefaultDecoration(widget.strings.cvvLabel),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return widget.strings.requiredError;
                        }
                        if (!CardUtils.validateCVV(value)) {
                          return widget.strings.invalidCvvError;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: widget.buttonStyle ??
                    ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(widget.amountText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
