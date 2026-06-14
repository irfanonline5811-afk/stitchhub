# OrderTrackingModel Documentation

## Overview
`OrderTrackingEvent` represents a tracking event in the order lifecycle. It tracks status changes and location updates for orders.

## File Location
`lib/models/order_tracking_model.dart`

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String` | Yes | Unique tracking event identifier |
| `orderId` | `String` | Yes | Associated order ID |
| `status` | `OrderStatus` | Yes | Order status at this event |
| `description` | `String` | Yes | Event description |
| `timestamp` | `DateTime` | Yes | Event timestamp |
| `latitude` | `double?` | No | Location latitude |
| `longitude` | `double?` | No | Location longitude |
| `locationName` | `String?` | No | Location name |

## Methods

### `fromMap(Map<String, dynamic> map)`
Factory constructor to create an `OrderTrackingEvent` from a Firestore document map.

### `toMap()`
Converts the `OrderTrackingEvent` to a Map for Firestore storage.

## Usage Example

```dart
final trackingEvent = OrderTrackingEvent(
  id: 'track123',
  orderId: 'order123',
  status: OrderStatus.inProgress,
  description: 'Order is being processed',
  timestamp: DateTime.now(),
  latitude: 40.7128,
  longitude: -74.0060,
  locationName: 'Tailor Shop',
);
```

## Related Files
- `lib/services/order_tracking_service.dart` - Tracking operations
- `lib/models/order_model.dart` - Order model

