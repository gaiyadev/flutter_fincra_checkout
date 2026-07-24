/// Represents the card brand based on its prefix.
enum CardBrand {
  visa,
  mastercard,
  verve,
  americanExpress,
  discover,
  unknown,
}

/// A model representing the details of a credit/debit card.
class CardDetails {
  final String cardNumber;
  final String cvv;
  final int expiryMonth;
  final int expiryYear;

  CardDetails({
    required this.cardNumber,
    required this.cvv,
    required this.expiryMonth,
    required this.expiryYear,
  });

  /// The raw card number with spaces removed.
  String get cleanCardNumber => cardNumber.replaceAll(' ', '');

  /// Determines the card brand based on common BIN prefixes.
  CardBrand get brand {
    final clean = cleanCardNumber;
    if (clean.startsWith(RegExp(r'^4'))) {
      return CardBrand.visa;
    } else if (clean.startsWith(RegExp(r'^(5[1-5]|2[2-7])'))) {
      return CardBrand.mastercard;
    } else if (clean.startsWith(RegExp(r'^(5060|5061|5078|6500)'))) {
      return CardBrand.verve;
    } else if (clean.startsWith(RegExp(r'^3[47]'))) {
      return CardBrand.americanExpress;
    } else if (clean.startsWith(RegExp(r'^6(?:011|5)'))) {
      return CardBrand.discover;
    }
    return CardBrand.unknown;
  }
}
