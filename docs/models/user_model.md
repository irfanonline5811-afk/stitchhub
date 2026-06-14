# UserModel Documentation

## Overview
`UserModel` represents a user in the StitchHub application. It can be either a customer or a tailor.

## File Location
`lib/models/user_model.dart`

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String` | Yes | Unique user identifier |
| `email` | `String` | Yes | User's email address |
| `name` | `String` | Yes | User's full name |
| `phone` | `String` | Yes | User's phone number |
| `userType` | `String` | Yes | User type: 'customer' or 'tailor' |
| `profileImageUrl` | `String?` | No | URL of user's profile image |
| `createdAt` | `DateTime` | Yes | Account creation timestamp |
| `updatedAt` | `DateTime` | Yes | Last update timestamp |

## Methods

### `fromMap(Map<String, dynamic> map)`
Factory constructor to create a `UserModel` from a Firestore document map.

**Parameters:**
- `map`: Map containing user data from Firestore

**Returns:** `UserModel` instance

**Example:**
```dart
final userMap = {
  'id': 'user123',
  'email': 'user@example.com',
  'name': 'John Doe',
  'phone': '1234567890',
  'userType': 'customer',
  'createdAt': 1234567890000,
  'updatedAt': 1234567890000,
};
final user = UserModel.fromMap(userMap);
```

### `toMap()`
Converts the `UserModel` to a Map for Firestore storage.

**Returns:** `Map<String, dynamic>` containing all user properties

**Example:**
```dart
final userMap = user.toMap();
await firestore.collection('users').doc(user.id).set(userMap);
```

### `copyWith({...})`
Creates a copy of the `UserModel` with updated values.

**Parameters:** All properties are optional

**Returns:** New `UserModel` instance with updated values

**Example:**
```dart
final updatedUser = user.copyWith(
  name: 'Jane Doe',
  profileImageUrl: 'https://example.com/image.jpg',
);
```

## Usage Example

```dart
// Create a new user
final user = UserModel(
  id: 'user123',
  email: 'john@example.com',
  name: 'John Doe',
  phone: '1234567890',
  userType: 'customer',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Convert to map for storage
final userMap = user.toMap();

// Create from map
final userFromMap = UserModel.fromMap(userMap);

// Update user
final updatedUser = user.copyWith(name: 'John Smith');
```

## Related Files
- `lib/services/auth_service.dart` - Uses UserModel for authentication
- `lib/providers/auth_provider.dart` - Manages UserModel state
- `lib/models/tailor_model.dart` - Extended model for tailors

