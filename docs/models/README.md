# Models Documentation

This directory contains documentation for all data models used in the StitchHub application.

## Available Models

### Core Models
- **[UserModel](user_model.md)** - Base user model for customers and tailors
- **[TailorModel](tailor_model.md)** - Extended user model for tailors with business information
- **[OrderModel](order_model.md)** - Order management model
- **[PaymentModel](payment_model.md)** - Payment transaction model

### Service Models
- **[AppointmentModel](appointment_model.md)** - Appointment booking model
- **[MeasurementModel](measurement_model.md)** - Measurement request/record model
- **[ReviewModel](review_model.md)** - Review and rating model
- **[MessageModel](message_model.md)** - Chat message and conversation model

### Supporting Models
- **[AddressModel](address_model.md)** - User address model
- **[OrderTrackingModel](order_tracking_model.md)** - Order tracking events
- **[CustomerVisitModel](customer_visit_model.md)** - Customer visit records
- **[SearchFilterModel](search_filter_model.md)** - Search filter and sorting options

## Model Structure

All models follow a consistent pattern:
- Factory constructor `fromMap()` for Firestore deserialization
- `toMap()` method for Firestore serialization
- `copyWith()` method for immutable updates (where applicable)
- Proper enum handling for status fields

## Usage Pattern

```dart
// Create from Firestore
final doc = await firestore.collection('users').doc('user123').get();
final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);

// Save to Firestore
await firestore.collection('users').doc(user.id).set(user.toMap());

// Update immutably
final updatedUser = user.copyWith(name: 'New Name');
```

## Related Documentation
- [Services Documentation](../services/README.md)
- [Providers Documentation](../providers/README.md)
- [Screens Documentation](../screens/README.md)

