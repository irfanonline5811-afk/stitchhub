# MeasurementModel Documentation

## Overview
`MeasurementModel` represents a measurement request/record between a customer and tailor. It tracks measurement appointments and recorded measurements.

## File Location
`lib/models/measurement_model.dart`

## Enums

### MeasurementStatus
- `pending` - Measurement request is pending
- `scheduled` - Appointment has been scheduled
- `completed` - Measurements have been completed
- `cancelled` - Request has been cancelled

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String` | Yes | Unique measurement identifier |
| `customerId` | `String` | Yes | ID of the customer |
| `tailorId` | `String` | Yes | ID of the tailor |
| `customerName` | `String` | Yes | Name of the customer |
| `tailorName` | `String` | Yes | Name of the tailor |
| `status` | `MeasurementStatus` | No | Current status (default: pending) |
| `appointmentDate` | `DateTime?` | No | Scheduled appointment date |
| `appointmentTime` | `DateTime?` | No | Scheduled appointment time |
| `notes` | `String?` | No | Additional notes |
| `measurements` | `Map<String, double>` | No | Recorded measurements (chest, waist, etc.) |
| `createdAt` | `DateTime` | Yes | Creation timestamp |
| `updatedAt` | `DateTime` | Yes | Last update timestamp |

## Methods

### `fromMap(Map<String, dynamic> map)`
Factory constructor to create a `MeasurementModel` from a Firestore document map.

### `toMap()`
Converts the `MeasurementModel` to a Map for Firestore storage.

### `copyWith({...})`
Creates a copy of the `MeasurementModel` with updated values.

## Usage Example

```dart
final measurement = MeasurementModel(
  id: 'measurement123',
  customerId: 'customer123',
  tailorId: 'tailor123',
  customerName: 'John Doe',
  tailorName: 'Jane Tailor',
  status: MeasurementStatus.scheduled,
  appointmentDate: DateTime(2024, 1, 15),
  appointmentTime: DateTime(2024, 1, 15, 14, 0),
  measurements: {
    'chest': 40.0,
    'waist': 32.0,
    'shoulder': 18.0,
  },
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

## Related Files
- `lib/services/measurement_service.dart` - Measurement operations
- `lib/providers/measurement_provider.dart` - Measurement state management
- `lib/screens/customer/request_measurement_screen.dart` - Request UI
- `lib/screens/tailor/take_measurement_screen.dart` - Take measurement UI

