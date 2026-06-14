import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/order_tracking_model.dart';

class OrderTrackingService {
  final _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // Add a tracking event
  Future<void> addTrackingEvent({
    required String orderId,
    required OrderStatus status,
    required String description,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    try {
      final eventId = _uuid.v4();
      final event = OrderTrackingEvent(
        id: eventId,
        orderId: orderId,
        status: status,
        description: description,
        timestamp: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
      );

      await _supabase.from('order_tracking').insert(event.toMap());

      // Update order with current location if provided
      if (latitude != null && longitude != null) {
        await _supabase.from('orders').update({
          'current_latitude': latitude,
          'current_longitude': longitude,
          'current_location_name': locationName,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', orderId);
      }
    } catch (e) {
      throw Exception('Failed to add tracking event: $e');
    }
  }

  // Get tracking history for an order
  Future<List<OrderTrackingEvent>> getTrackingHistory(String orderId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('order_tracking')
          .select()
          .eq('order_id', orderId)
          .order('timestamp', ascending: true);

      return data.map((e) => OrderTrackingEvent.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to get tracking history: $e');
    }
  }

  // Stream tracking history for real-time updates
  Stream<List<OrderTrackingEvent>> streamTrackingHistory(String orderId) {
    return _supabase
        .from('order_tracking')
        .stream(primaryKey: ['id'])
        .eq('order_id', orderId)
        .order('timestamp', ascending: true)
        .map((data) => data.map((e) => OrderTrackingEvent.fromMap(e)).toList());
  }

  // Update order location
  Future<void> updateOrderLocation({
    required String orderId,
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    try {
      await _supabase.from('orders').update({
        'current_latitude': latitude,
        'current_longitude': longitude,
        'current_location_name': locationName,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order location: $e');
    }
  }

  // Calculate and update estimated delivery date
  Future<void> updateEstimatedDeliveryDate({
    required String orderId,
    required DateTime estimatedDate,
  }) async {
    try {
      await _supabase.from('orders').update({
        'estimated_delivery_date': estimatedDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update estimated delivery date: $e');
    }
  }

  // Calculate estimated delivery date based on status
  DateTime? calculateEstimatedDeliveryDate(OrderModel order) {
    final now = DateTime.now();
    
    switch (order.status) {
      case OrderStatus.pending:
        return now.add(const Duration(days: 6));
      case OrderStatus.confirmed:
        return now.add(const Duration(days: 4));
      case OrderStatus.inProgress:
      case OrderStatus.cutting:
      case OrderStatus.stitching:
        return now.add(const Duration(days: 2));
      case OrderStatus.readyForPickup:
        return now.add(const Duration(days: 1));
      case OrderStatus.completed:
        return order.completedDate;
      default:
        return null;
    }
  }

  // Initialize tracking events when order status changes
  Future<void> initializeTrackingEvent({
    required String orderId,
    required OrderStatus status,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    String description;
    
    switch (status) {
      case OrderStatus.pending:
        description = 'Order placed and pending confirmation';
        break;
      case OrderStatus.confirmed:
        description = 'Order confirmed by tailor';
        break;
      case OrderStatus.inProgress:
        description = 'Order is being worked on';
        break;
      case OrderStatus.cutting:
        description = 'Fabric is being cut';
        break;
      case OrderStatus.stitching:
        description = 'Suit is being stitched';
        break;
      case OrderStatus.qualityCheck:
        description = 'Order is undergoing quality check';
        break;
      case OrderStatus.readyForPickup:
        description = 'Order is ready for pickup';
        break;
      case OrderStatus.completed:
        description = 'Order completed and delivered';
        break;
      case OrderStatus.cancelled:
        description = 'Order has been cancelled';
        break;
    }

    await addTrackingEvent(
      orderId: orderId,
      status: status,
      description: description,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
  }
}
