class UrlHandler {
  /// Checks if the URL indicates a payment completion (success or failure)
  static bool isCompletionUrl(String url, {String? expectedRedirectUrl}) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    if (expectedRedirectUrl != null && expectedRedirectUrl.isNotEmpty) {
      // If the developer provided an expected redirect URL, ANY navigation to it 
      // means the Fincra flow has finished. We shouldn't strictly enforce 'status'
      return url.startsWith(expectedRedirectUrl);
    }

    // Fallback if no redirect URL was given: Fincra usually appends `status` and `reference`
    return (uri.queryParameters.containsKey('status') || uri.queryParameters.containsKey('payment_status')) &&
        uri.queryParameters.containsKey('reference');
  }

  /// Extracts the response parameters from the URL
  static Map<String, String> extractResponseParams(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return {};

    return uri.queryParameters;
  }
}
