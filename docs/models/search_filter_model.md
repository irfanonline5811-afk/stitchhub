# SearchFilterModel Documentation

## Overview
`SearchFilterModel` represents search filters and sorting options for tailor searches.

## File Location
`lib/models/search_filter_model.dart`

## Enums

### TailorSortBy
- `relevance` - Sort by relevance
- `ratingDesc` - Sort by rating (high to low)
- `distanceAsc` - Sort by distance (near to far)
- `priceAsc` - Sort by price (low to high)

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `minRating` | `double?` | No | Minimum rating filter |
| `maxPrice` | `double?` | No | Maximum price filter |
| `maxDistanceKm` | `double?` | No | Maximum distance in kilometers |
| `services` | `List<String>` | No | Filter by service types (default: empty) |
| `sortBy` | `TailorSortBy` | No | Sort option (default: relevance) |

## Methods

### `copyWith({...})`
Creates a copy of the `SearchFilterModel` with updated values.

## Usage Example

```dart
final filters = SearchFilterModel(
  minRating: 4.0,
  maxPrice: 2000.0,
  maxDistanceKm: 10.0,
  services: ['shirt', 'pants'],
  sortBy: TailorSortBy.ratingDesc,
);

// Update filters
final updatedFilters = filters.copyWith(
  minRating: 4.5,
  sortBy: TailorSortBy.distanceAsc,
);
```

## Related Files
- `lib/providers/tailor_provider.dart` - Uses filters for search
- `lib/screens/customer/search_tailors_screen.dart` - Search UI

