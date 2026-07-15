/// A cached HTTP response keyed by a stable string (URL + params hash).
class CachedApiResponse {
  const CachedApiResponse({
    required this.id,
    required this.cacheKey,
    required this.response,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String cacheKey;

  /// Raw JSON string of the response body.
  final String response;

  final DateTime createdAt;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
