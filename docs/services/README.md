# Services Documentation

This directory contains documentation for all service classes in the StitchHub application. Services handle business logic and interact with Firebase services.

## Available Services

### Authentication & User Services
- **[AuthService](auth_service.md)** - User authentication, registration, and profile management

### Core Business Services
- **[OrderService](order_service.md)** - Order creation, management, and status updates
- **[TailorService](tailor_service.md)** - Tailor search, profile management, and availability
- **[PaymentService](payment_service.md)** - Payment processing and transaction management

### Feature Services
- **[AppointmentService](appointment_service.md)** - Appointment booking and management
- **[MeasurementService](measurement_service.md)** - Measurement requests and records
- **[ReviewService](review_service.md)** - Review and rating management
- **[ChatService](chat_service.md)** - Messaging and chat functionality

### Supporting Services
- **[AddressService](address_service.md)** - Address management
- **[FavoriteService](favorite_service.md)** - Favorite tailors management
- **[OrderTrackingService](order_tracking_service.md)** - Order tracking events
- **[CustomerVisitService](customer_visit_service.md)** - Customer visit records
- **[NotificationService](notification_service.md)** - Push notifications
- **[ReferralService](referral_service.md)** - Referral system

## Service Architecture

All services follow a consistent pattern:
- Direct interaction with Firebase (Firestore, Storage, Auth)
- Business logic encapsulation
- Error handling with meaningful exceptions
- Model-based data structures

## Usage Pattern

```dart
// Initialize service
final service = OrderService();

// Perform operation
try {
  final order = await service.createOrder(orderModel);
} catch (e) {
  // Handle error
  print('Error: $e');
}
```

## Related Documentation
- [Models Documentation](../models/README.md)
- [Providers Documentation](../providers/README.md)
- [Screens Documentation](../screens/README.md)

