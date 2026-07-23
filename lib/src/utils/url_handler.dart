class UrlHandler {
  /// Checks if the URL indicates a payment completion (success or failure)
  static bool isCompletionUrl(String url, {String? expectedRedirectUrl}) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    if (expectedRedirectUrl != null && expectedRedirectUrl.isNotEmpty) {
      return url.startsWith(expectedRedirectUrl) &&
          uri.queryParameters.containsKey('status');
    }

    // Fincra appends `status` and `reference` to the redirect URL
    return uri.queryParameters.containsKey('status') &&
        uri.queryParameters.containsKey('reference');
  }

  /// Extracts the response parameters from the URL
  static Map<String, String> extractResponseParams(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return {};

    return uri.queryParameters;
  }
}
