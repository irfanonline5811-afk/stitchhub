# OrderModel Documentation

## Overview
`OrderModel` represents an order placed by a customer with a tailor in the StitchHub application. It contains all order details including status, payment information, and tracking data.

## File Location
`lib/models/order_model.dart`

## Enums

### OrderStatus
Represents the current status of an order.

- `pending` - Order is pending confirmation
- `confirmed` - Order has been confirmed by tailor
- `inProgress` - Order is being worked on
- `readyForPickup` - Order is ready for pickup
- `completed` - Order is completed
- `cancelled` - Order has been cancelled

### PaymentStatus
Represents the payment status of an order.

- `pending` - Payment is pending
- `paid` - Payment has been completed
- `failed` - Payment failed
- `refunded` - Payment has been refunded

### PaymentMethod
Represents the payment method used.

- `cashOnDelivery` - Cash on delivery
- `online` - Online payment

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String` | Yes | Unique order identifier |
| `customerId` | `String` | Yes | ID of the customer |
| `tailorId` | `String` | Yes | ID of the tailor |
| `customerName` | `String` | Yes | Name of the customer |
| `tailorName` | `String` | Yes | Name of the tailor |
| `serviceType` | `String` | Yes | Type of service (e.g., 'shirt', 'pants') |
| `description` | `String` | Yes | Order description |
| `images` | `List<String>` | No | Images of items to be stitched |
| `measurements` | `Map<String, dynamic>` | No | Custom measurements |
| `price` | `double` | Yes | Order price |
| `status` | `OrderStatus` | No | Current order status (default: pending) |
| `paymentStatus` | `PaymentStatus` | No | Payment status (default: pending) |
| `paymentMethod` | `PaymentMethod` | No | Payment method (default: cashOnDelivery) |
| `orderDate` | `DateTime` | Yes | Order placement date |
| `confirmedDate` | `DateTime?` | No | Order confirmation date |
| `completedDate` | `DateTime?` | No | Order completion date |
| `pickupDate` | `DateTime?` | No | Pickup date |
| `deliveryDate` | `DateTime?` | No | Delivery date |
| `estimatedDeliveryDate` | `DateTime?` | No | Estimated delivery date |
| `notes` | `String?` | No | Additional notes |
| `customerAddress` | `String?` | No | Customer address |
| `tailorAddress` | `String?` | No | Tailor address |
| `currentLatitude` | `double?` | No | Current location latitude |
| `currentLongitude` | `double?` | No | Current location longitude |
| `currentLocationName` | `String?` | No | Current location name |
| `rating` | `double?` | No | Order rating |
| `review` | `String?` | No | Order review |
| `createdAt` | `DateTime` | Yes | Creation timestamp |
| `updatedAt` | `DateTime` | Yes | Last update timestamp |

## Methods

### `fromMap(Map<String, dynamic> map)`
Factory constructor to create an `OrderModel` from a Firestore document map.

**Parameters:**
- `map`: Map containing order data from Firestore

**Returns:** `OrderModel` instance

### `toMap()`
Converts the `OrderModel` to a Map for Firestore storage.

**Returns:** `Map<String, dynamic>` containing all order properties

### `copyWith({...})`
Creates a copy of the `OrderModel` with updated values.

**Parameters:** All properties are optional

**Returns:** New `OrderModel` instance with updated values

## Usage Example

```dart
// Create a new order
final order = OrderModel(
  id: 'order123',
  customerId: 'customer123',
  tailorId: 'tailor123',
  customerName: 'John Doe',
  tailorName: 'Jane Tailor',
  serviceType: 'shirt',
  description: 'Custom shirt with specific measurements',
  images: ['https://example.com/image1.jpg'],
  measurements: {'chest': 40, 'waist': 32},
  price: 1500.0,
  status: OrderStatus.pending,
  paymentStatus: PaymentStatus.pending,
  paymentMethod: PaymentMethod.cashOnDelivery,
  orderDate: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Update order status
final updatedOrder = order.copyWith(
  status: OrderStatus.confirmed,
  confirmedDate: DateTime.now(),
);
```

## Related Files
- `lib/services/order_service.dart` - Handles order operations
- `lib/providers/order_provider.dart` - Manages order state
- `lib/screens/customer/place_order_screen.dart` - Order creation UI
- `lib/screens/customer/order_detail_screen.dart` - Order details UI

