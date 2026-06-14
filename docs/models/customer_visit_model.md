# CustomerVisitModel Documentation

## Overview
`CustomerVisitModel` represents a customer visit record to a tailor's shop. Used for tracking in-person visits.

## File Location
`lib/models/customer_visit_model.dart`

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String` | Yes | Unique visit identifier |
| `customerId` | `String` | Yes | ID of the customer |
| `tailorId` | `String` | Yes | ID of the tailor |
| `customerName` | `String` | Yes | Name of the customer |
| `tailorName` | `String` | Yes | Name of the tailor |
| `customerPhone` | `String` | Yes | Customer phone number |
| `customerEmail` | `String?` | No | Customer email |
| `customerAddress` | `String?` | No | Customer address |
| `notes` | `String?` | No | Visit notes |
| `visitDate` | `DateTime` | Yes | Visit date and time |
| `createdAt` | `DateTime` | Yes | Creation timestamp |
| `updatedAt` | `DateTime` | Yes | Last update timestamp |

## Methods

### `fromMap(Map<String, dynamic> map)`
Factory constructor to create a `CustomerVisitModel` from a Firestore document map.

### `toMap()`
Converts the `CustomerVisitModel` to a Map for Firestore storage.

### `copyWith({...})`
Creates a copy of the `CustomerVisitModel` with updated values.

## Usage Example

```dart
final visit = CustomerVisitModel(
  id: 'visit123',
  customerId: 'customer123',
  tailorId: 'tailor123',
  customerName: 'John Doe',
  tailorName: 'Jane Tailor',
  customerPhone: '1234567890',
  customerEmail: 'john@example.com',
  visitDate: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

## Related Files
- `lib/services/customer_visit_service.dart` - Visit operations

