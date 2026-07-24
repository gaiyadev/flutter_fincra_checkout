import 'package:flutter/services.dart';

class CardUtils {
  /// Validates a card number using the Luhn algorithm.
  static bool validateCardNumber(String input) {
    if (input.isEmpty) return false;

    String text = input.replaceAll(RegExp(r'\s+\b|\b\s'), '');
    if (!RegExp(r'^[0-9]+$').hasMatch(text)) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = text.length - 1; i >= 0; i--) {
      int digit = int.parse(text[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Validates an expiry date (MM/YY format).
  static bool validateDate(String input) {
    if (input.isEmpty) return false;
    
    final parts = input.split('/');
    if (parts.length != 2) return false;
    
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    
    final now = DateTime.now();
    // Assuming YY format (e.g., 23 means 2023)
    final fullYear = year + 2000;
    
    if (fullYear < now.year) return false;
    if (fullYear == now.year && month < now.month) return false;
    
    return true;
  }
  
  /// Validates a CVV code.
  static bool validateCVV(String input) {
    if (input.isEmpty) return false;
    if (input.length < 3 || input.length > 4) return false;
    if (!RegExp(r'^[0-9]+$').hasMatch(input)) return false;
    return true;
  }
}

/// A text input formatter that automatically formats card numbers 
/// by inserting a space after every 4 digits.
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    var newText = '';
    
    for (int i = 0; i < text.length; i++) {
      newText += text[i];
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        newText += ' ';
      }
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

/// A text input formatter that automatically formats expiry dates 
/// by inserting a slash (/) after the month (MM/YY).
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');
    
    if (text.isNotEmpty) {
      // If the first digit is > 1, assume it's a single digit month, prefix with 0
      if (text.length == 1) {
        final val = int.tryParse(text);
        if (val != null && val > 1) {
          text = '0$val';
        }
      }
      
      if (text.length > 2) {
        text = '${text.substring(0, 2)}/${text.substring(2)}';
      }
    }
    
    // Restrict to max length of MM/YY
    if (text.length > 5) {
      text = text.substring(0, 5);
    }
    
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
