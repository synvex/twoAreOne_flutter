/// HTTP verbs supported by [ApiRequest]. Kept as an enum instead of a raw
/// string so a typo like "gett" fails at compile time, not at runtime.
enum ApiMethod { get, post, put, delete, patch }


class ApiRequest {
  final ApiMethod method;
  final String url;
  final Map<String, String>? headers;

  const ApiRequest({
    required this.method,
    required this.url,
    this.headers,
  });
}

class ApiEndpoints {
  ApiEndpoints._();

  static const ApiRequest privacyPolicy = ApiRequest(
    method: ApiMethod.get,
    url: '/pages/privacy-policy', // adjust to match actual backend route
  );

  // Example of how the next screen (e.g. Terms & Conditions) plugs in:
  static const ApiRequest termsAndConditions = ApiRequest(
    method: ApiMethod.get,
    url: '/pages/terms-and-conditions',
  );
}