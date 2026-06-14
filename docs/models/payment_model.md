# PaymentModel Documentation

## Overview
`PaymentModel` represents a payment transaction for an order. It integrates with Stripe for online payments.

## File Location
`lib/models/payment_model.dart`

## Enums

### PaymentTransactionStatus
- `pending` - Payment is pending
- `processing` - Payment is being processed
- `succeeded` - Payment succeeded
- `failed` - Payment failed
- `cancelled` - Payment was cancelled
- `refunded` - Payment has been refunded

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String` | Yes | Unique payment identifier |
| `orderId` | `String` | Yes | Associated order ID |
| `customerId` | `String` | Yes | ID of the customer |
| `paymentIntentId` | `String?` | No | Stripe Payment Intent ID |
| `customerStripeId` | `String?` | No | Stripe Customer ID |
| `amount` | `double` | Yes | Payment amount |
| `currency` | `String` | No | Currency code (default: 'usd') |
| `status` | `PaymentTransactionStatus` | No | Payment status (default: pending) |
| `failureReason` | `String?` | No | Reason for payment failure |
| `metadata` | `Map<String, dynamic>?` | No | Additional metadata |
| `createdAt` | `DateTime` | Yes | Creation timestamp |
| `updatedAt` | `DateTime` | Yes | Last update timestamp |

## Methods

### `fromMap(Map<String, dynamic> map)`
Factory constructor to create a `PaymentModel` from a Firestore document map.

### `toMap()`
Converts the `PaymentModel` to a Map for Firestore storage.

### `copyWith({...})`
Creates a copy of the `PaymentModel` with updated values.

## Usage Example

```dart
final payment = PaymentModel(
  id: 'payment123',
  orderId: 'order123',
  customerId: 'customer123',
  amount: 1500.0,
  currency: 'usd',
  status: PaymentTransactionStatus.pending,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

## Related Files
- `lib/services/payment_service.dart` - Payment operations
- `lib/providers/payment_provider.dart` - Payment state management
- `lib/screens/customer/payment_screen.dart` - Payment UI

