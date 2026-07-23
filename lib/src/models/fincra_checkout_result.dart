import 'fincra_response.dart';
import 'fincra_error.dart';

/// Represents the possible outcomes of a Fincra Checkout session.
sealed class FincraCheckoutResult {}

/// Returned when the payment is successful.
class FincraCheckoutSuccess extends FincraCheckoutResult {
  final FincraPaymentResponse response;

  FincraCheckoutSuccess(this.response);
}

/// Returned when the payment fails or encounters an error.
class FincraCheckoutError extends FincraCheckoutResult {
  final FincraPaymentError error;

  FincraCheckoutError(this.error);
}

/// Returned when the user cancels the payment process.
class FincraCheckoutCancelled extends FincraCheckoutResult {}
