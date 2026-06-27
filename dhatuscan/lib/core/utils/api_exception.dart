/// A typed exception for all API-layer failures.
///
/// Covers HTTP error responses, connectivity failures, and timeouts.
/// Consumers can inspect [statusCode] to branch on 401, 4xx, 5xx, etc.
class ApiException implements Exception {
  /// HTTP status code returned by the server, or a synthetic code:
  /// - `0`  → no network / connectivity pre-flight failed
  /// - `-1` → connection timed out
  final int statusCode;

  /// Human-readable description of the failure.
  final String message;

  const ApiException({required this.statusCode, required this.message});

  /// Returns `true` when the server rejected the request as unauthorised.
  bool get isUnauthorised => statusCode == 401;

  /// Returns `true` when the device was offline before the request was sent.
  bool get isOffline => statusCode == 0;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
