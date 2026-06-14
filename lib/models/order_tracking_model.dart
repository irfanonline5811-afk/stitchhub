import 'order_model.dart';

class OrderTrackingEvent {
  final String id;
  final String orderId;
  final OrderStatus status;
  final String description;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  OrderTrackingEvent({
    required this.id,
    required this.orderId,
    required this.status,
    required this.description,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  factory OrderTrackingEvent.fromMap(Map<String, dynamic> map) {
    return OrderTrackingEvent(
      id: map['id'] ?? '',
      orderId: map['order_id'] ?? map['orderId'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp'].toString())
          : DateTime.fromMillisecondsSinceEpoch(map['timestampMs'] ?? 0),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      locationName: map['location_name'] ?? map['locationName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'status': status.toString().split('.').last,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
    };
  }
}
