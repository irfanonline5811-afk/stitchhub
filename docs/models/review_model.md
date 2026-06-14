# ReviewModel Documentation

## Overview
`ReviewModel` represents a review/rating given by a customer to a tailor after order completion.

## File Location
`lib/models/review_model.dart`

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String` | Yes | Unique review identifier |
| `tailorId` | `String` | Yes | ID of the tailor being reviewed |
| `customerId` | `String` | Yes | ID of the customer giving review |
| `customerName` | `String` | Yes | Name of the customer |
| `customerImageUrl` | `String?` | No | Customer's profile image URL |
| `rating` | `double` | Yes | Rating from 1.0 to 5.0 |
| `comment` | `String?` | No | Review comment/text |
| `images` | `List<String>` | No | Images attached to review |
| `createdAt` | `DateTime` | Yes | Review creation timestamp |

## Methods

### `fromMap(Map<String, dynamic> map)`
Factory constructor to create a `ReviewModel` from a Firestore document map.

### `toMap()`
Converts the `ReviewModel` to a Map for Firestore storage.

## Usage Example

```dart
final review = ReviewModel(
  id: 'review123',
  tailorId: 'tailor123',
  customerId: 'customer123',
  customerName: 'John Doe',
  rating: 4.5,
  comment: 'Great service and quality work!',
  images: ['https://example.com/review1.jpg'],
  createdAt: DateTime.now(),
);
```

## Related Files
- `lib/services/review_service.dart` - Review operations
- `lib/providers/review_provider.dart` - Review state management

