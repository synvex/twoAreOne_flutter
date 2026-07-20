/// Renamed from a generic `ApiRequest` to avoid colliding with the app's
/// existing `Api` / `ApiRequest` classes used by its real `ApiManager` /
/// `Api_Manager` (Dio-based). This one is scoped to `InterestedApiClient`
/// only - see that file's doc comment for how to swap it out entirely for
/// your existing Dio manager instead.
///
/// Mirrors the plain-object "service" pattern used throughout the RN app,
/// e.g.:
/// ```js
/// export const BlockUserService = {
///   method: 'POST',
///   url: '/user/user-add-block-profile.php',
///   headers: { 'Content-Type': 'application/json' },
/// };
/// ```
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
