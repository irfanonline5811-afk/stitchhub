enum TailorSortBy {
  relevance,
  ratingDesc,
  distanceAsc,
  priceAsc,
}

class SearchFilterModel {
  final double? minRating;
  final double? maxPrice;
  final double? maxDistanceKm;
  final List<String> services; // lowercased service keys
  final TailorSortBy sortBy;

  const SearchFilterModel({
    this.minRating,
    this.maxPrice,
    this.maxDistanceKm,
    this.services = const [],
    this.sortBy = TailorSortBy.relevance,
  });

  SearchFilterModel copyWith({
    double? minRating,
    double? maxPrice,
    double? maxDistanceKm,
    List<String>? services,
    TailorSortBy? sortBy,
  }) {
    return SearchFilterModel(
      minRating: minRating ?? this.minRating,
      maxPrice: maxPrice ?? this.maxPrice,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      services: services ?? this.services,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}












