# TailorModel Documentation

## Overview
`TailorModel` extends `UserModel` and represents a tailor in the StitchHub application. It includes business-specific information like location, pricing, availability, and services.

## File Location
`lib/models/tailor_model.dart`

## Inheritance
Extends `UserModel` with `userType: 'tailor'`

## Additional Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `businessName` | `String?` | No | Name of the tailor's business |
| `businessAddress` | `String?` | No | Business address |
| `latitude` | `double` | Yes | Business location latitude |
| `longitude` | `double` | Yes | Business location longitude |
| `specialties` | `List<String>` | No | List of tailor specialties |
| `workSamples` | `List<String>` | No | URLs of work sample images |
| `pricing` | `Map<String, double>` | No | Service type to price mapping |
| `availableDays` | `List<String>` | No | Available days of the week |
| `startTime` | `String` | No | Business start time (default: "09:00") |
| `endTime` | `String` | No | Business end time (default: "18:00") |
| `rating` | `double` | No | Average rating (default: 0.0) |
| `totalReviews` | `int` | No | Total number of reviews (default: 0) |
| `isAvailable` | `bool` | No | Availability status (default: true) |
| `description` | `String?` | No | Business description |
| `services` | `List<String>` | No | List of services offered |

## Methods

### `fromMap(Map<String, dynamic> map)`
Factory constructor to create a `TailorModel` from a Firestore document map.

### `toMap()`
Converts the `TailorModel` to a Map for Firestore storage. Includes both UserModel and TailorModel properties.

### `copyWithTailor({...})`
Creates a copy of the `TailorModel` with updated values.

## Usage Example

```dart
final tailor = TailorModel(
  id: 'tailor123',
  email: 'tailor@example.com',
  name: 'Jane Tailor',
  phone: '1234567890',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  businessName: 'Jane\'s Tailoring',
  businessAddress: '123 Main St',
  latitude: 40.7128,
  longitude: -74.0060,
  services: ['shirt', 'pants', 'dress'],
  pricing: {'shirt': 1500.0, 'pants': 2000.0},
  rating: 4.5,
  totalReviews: 25,
  isAvailable: true,
);
```

## Related Files
- `lib/models/user_model.dart` - Base class
- `lib/services/tailor_service.dart` - Tailor operations
- `lib/providers/tailor_provider.dart` - Tailor state management

