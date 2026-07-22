
class InterestedApiRequest {
  final String method; // 'GET' | 'POST'
  final String path; // relative path, e.g. '/user/users-interest.php'
  final Map<String, String> headers;

  const InterestedApiRequest({
    required this.method,
    required this.path,
    this.headers = const {'Content-Type': 'application/json'},
  });
}
