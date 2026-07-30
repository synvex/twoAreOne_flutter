class FavouriteApiException implements Exception {
  final String message;
  const FavouriteApiException(this.message);

  @override
  String toString() => message;
}
