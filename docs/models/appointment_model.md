# AppointmentModel Documentation

## Overview
`AppointmentModel` represents an appointment between a customer and tailor for consultations, fittings, or other services.

## File Location
`lib/models/appointment_model.dart`

## Enums

### AppointmentStatus
- `pending` - Appointment request is pending approval
- `approved` - Appointment has been approved by tailor
- `declined` - Appointment has been declined
- `cancelled` - Appointment has been cancelled
- `completed` - Appointment has been completed

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String` | Yes | Unique appointment identifier |
| `customerId` | `String` | Yes | ID of the customer |
| `customerName` | `String` | Yes | Name of the customer |
| `tailorId` | `String` | Yes | ID of the tailor |
| `tailorName` | `String` | Yes | Name of the tailor |
| `startTime` | `DateTime` | Yes | Appointment start time |
| `endTime` | `DateTime` | Yes | Appointment end time |
| `notes` | `String?` | No | Additional notes |
| `status` | `AppointmentStatus` | No | Current status (default: pending) |
| `createdAt` | `DateTime` | Yes | Creation timestamp |
| `updatedAt` | `DateTime` | Yes | Last update timestamp |

## Methods

### `fromMap(Map<String, dynamic> map)`
Factory constructor to create an `AppointmentModel` from a Firestore document map.

### `toMap()`
Converts the `AppointmentModel` to a Map for Firestore storage.

## Usage Example

```dart
final appointment = AppointmentModel(
  id: 'appointment123',
  customerId: 'customer123',
  customerName: 'John Doe',
  tailorId: 'tailor123',
  tailorName: 'Jane Tailor',
  startTime: DateTime(2024, 1, 15, 14, 0),
  endTime: DateTime(2024, 1, 15, 15, 0),
  status: AppointmentStatus.pending,
  notes: 'First consultation',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

## Related Files
- `lib/services/appointment_service.dart` - Appointment operations
- `lib/providers/appointment_provider.dart` - Appointment state management
- `lib/screens/customer/book_appointment_screen.dart` - Booking UI
- `lib/screens/tailor/tailor_appointments_screen.dart` - Tailor appointments UI

