# AuthService Documentation

## Overview
`AuthService` handles all authentication-related operations including user registration, login, profile management, and profile image uploads. It integrates with Firebase Authentication and Firestore.

## File Location
`lib/services/auth_service.dart`

## Dependencies
- `firebase_auth` - Firebase Authentication
- `cloud_firestore` - Firestore database
- `firebase_storage` - Firebase Storage for images

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `currentUser` | `User?` | Current Firebase authenticated user |

## Methods

### `signUp({required String email, required String password, required String name, required String phone, required String userType})`
Creates a new user account with Firebase Authentication and stores user data in Firestore.

**Parameters:**
- `email` - User's email address
- `password` - User's password
- `name` - User's full name
- `phone` - User's phone number
- `userType` - 'customer' or 'tailor'

**Returns:** `Future<UserModel?>` - Created user model or null

**Throws:** `Exception` if sign up fails

**Example:**
```dart
final authService = AuthService();
final user = await authService.signUp(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',
  phone: '1234567890',
  userType: 'customer',
);
```

### `signIn({required String email, required String password})`
Signs in an existing user with email and password.

**Parameters:**
- `email` - User's email address
- `password` - User's password

**Returns:** `Future<UserModel?>` - Signed in user model or null

**Throws:** `Exception` if sign in fails

### `signOut()`
Signs out the current user.

**Returns:** `Future<void>`

### `getCurrentUser()`
Retrieves the current authenticated user's data from Firestore.

**Returns:** `Future<UserModel?>` - Current user model or null

**Throws:** `Exception` if retrieval fails

### `updateProfile({String? name, String? phone, String? profileImageUrl})`
Updates the current user's profile information.

**Parameters:**
- `name` - Updated name (optional)
- `phone` - Updated phone (optional)
- `profileImageUrl` - Updated profile image URL (optional)

**Returns:** `Future<UserModel?>` - Updated user model

**Throws:** `Exception` if update fails

### `uploadProfileImage(File imageFile, String userId)`
Uploads a profile image to Firebase Storage and returns the download URL.

**Parameters:**
- `imageFile` - Image file to upload
- `userId` - User ID

**Returns:** `Future<String>` - Download URL of uploaded image

**Throws:** `Exception` if upload fails

## Usage Example

```dart
final authService = AuthService();

// Sign up
final newUser = await authService.signUp(
  email: 'john@example.com',
  password: 'password123',
  name: 'John Doe',
  phone: '1234567890',
  userType: 'customer',
);

// Sign in
final user = await authService.signIn(
  email: 'john@example.com',
  password: 'password123',
);

// Get current user
final currentUser = await authService.getCurrentUser();

// Update profile
final updatedUser = await authService.updateProfile(
  name: 'John Smith',
  phone: '0987654321',
);

// Upload profile image
final imageFile = File('path/to/image.jpg');
final imageUrl = await authService.uploadProfileImage(imageFile, user.id);
```

## Related Files
- `lib/providers/auth_provider.dart` - Uses AuthService for state management
- `lib/models/user_model.dart` - User data model
- `lib/models/tailor_model.dart` - Tailor data model

