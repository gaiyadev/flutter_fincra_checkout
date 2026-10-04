class UrlHandler {
  /// Checks if the URL indicates a payment completion (success or failure)
  static bool isCompletionUrl(String url, {String? expectedRedirectUrl}) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    if (expectedRedirectUrl != null && expectedRedirectUrl.isNotEmpty) {
      // If the developer provided an expected redirect URL, ANY navigation to it
      // means the Fincra flow has finished. We shouldn't strictly enforce 'status'
      return _matchesRedirectUrl(uri, url, expectedRedirectUrl);
    }

    // Fallback if no redirect URL was given: Fincra usually appends `status` and `reference`
    return (uri.queryParameters.containsKey('status') ||
            uri.queryParameters.containsKey('payment_status')) &&
        uri.queryParameters.containsKey('reference');
  }

  /// Extracts the response parameters from the URL
  static Map<String, String> extractResponseParams(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return {};

    return uri.queryParameters;
  }

  /// Returns the lowercased payment status from the completion URL params,
  /// reading `status` first and falling back to `payment_status`.
  ///
  /// Fincra might not append a status to the redirect URL in sandbox, so a
  /// missing status is treated as success. Always verify the transaction on
  /// your backend before fulfilling an order.
  static String extractStatus(Map<String, String> params) {
    return (params['status'] ?? params['payment_status'])?.toLowerCase() ??
        'success';
  }

  /// Compares scheme, host and port exactly, and requires the path to equal the
  /// expected path or continue it at a `/` boundary. Query and fragment are ignored.
  static bool _matchesRedirectUrl(Uri uri, String url, String expected) {
    final expectedUri = Uri.tryParse(expected);
    if (expectedUri == null ||
        !expectedUri.hasScheme ||
        expectedUri.host.isEmpty) {
      return url.startsWith(expected);
    }

    if (uri.scheme.toLowerCase() != expectedUri.scheme.toLowerCase() ||
        uri.host.toLowerCase() != expectedUri.host.toLowerCase() ||
        uri.port != expectedUri.port) {
      return false;
    }

    final expectedPath = _trimTrailingSlash(expectedUri.path);
    final path = _trimTrailingSlash(uri.path);
    return expectedPath.isEmpty ||
        path == expectedPath ||
        path.startsWith('$expectedPath/');
  }

  static String _trimTrailingSlash(String path) =>
      path.endsWith('/') ? path.substring(0, path.length - 1) : path;
}
