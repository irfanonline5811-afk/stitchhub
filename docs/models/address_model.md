# AddressModel Documentation

## Overview
`AddressModel` represents a saved address for a user (customer or tailor). Users can have multiple addresses with one marked as default.

## File Location
`lib/models/address_model.dart`

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String` | Yes | Unique address identifier |
| `userId` | `String` | Yes | ID of the user who owns this address |
| `label` | `String` | Yes | Address label (e.g., 'Home', 'Work') |
| `addressLine1` | `String` | Yes | Primary address line |
| `addressLine2` | `String?` | No | Secondary address line |
| `city` | `String` | Yes | City name |
| `state` | `String` | Yes | State/Province name |
| `country` | `String` | Yes | Country name |
| `postalCode` | `String` | Yes | Postal/ZIP code |
| `latitude` | `double?` | No | Address latitude coordinate |
| `longitude` | `double?` | No | Address longitude coordinate |
| `isDefault` | `bool` | No | Whether this is the default address (default: false) |
| `createdAt` | `DateTime` | Yes | Creation timestamp |
| `updatedAt` | `DateTime` | Yes | Last update timestamp |

## Methods

### `fromMap(Map<String, dynamic> map)`
Factory constructor to create an `AddressModel` from a Firestore document map.

### `toMap()`
Converts the `AddressModel` to a Map for Firestore storage.

## Usage Example

```dart
final address = AddressModel(
  id: 'address123',
  userId: 'user123',
  label: 'Home',
  addressLine1: '123 Main Street',
  addressLine2: 'Apt 4B',
  city: 'New York',
  state: 'NY',
  country: 'USA',
  postalCode: '10001',
  latitude: 40.7128,
  longitude: -74.0060,
  isDefault: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

## Related Files
- `lib/services/address_service.dart` - Address operations
- `lib/providers/address_provider.dart` - Address state management

