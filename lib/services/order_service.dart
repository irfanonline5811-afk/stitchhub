import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';
import 'notification_service.dart';

class OrderService {
  final _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      final String orderId = _uuid.v4();
      final orderWithId = order.copyWith(id: orderId);

      await _supabase.from('orders').insert(orderWithId.toMap());

      // Trigger notification for tailor
      await NotificationService().sendNewOrderNotification(
        tailorId: orderWithId.tailorId,
        customerName: orderWithId.customerName,
        orderId: orderWithId.id,
      );

      return orderWithId;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return data.map((e) => OrderModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch customer orders: $e');
    }
  }

  Future<List<OrderModel>> getTailorOrders(String tailorId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('orders')
          .select()
          .eq('tailor_id', tailorId)
          .order('created_at', ascending: false);

      return data.map((e) => OrderModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tailor orders: $e');
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final data = await _supabase.from('orders').select().eq('id', orderId).single();
      return OrderModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': status.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      };

      switch (status) {
        case OrderStatus.confirmed:
          updateData['confirmed_date'] = DateTime.now().toIso8601String();
          break;
        case OrderStatus.cutting:
          // You might want to track a cutting_start_date here if added to the model
          break;
        case OrderStatus.stitching:
          // You might want to track a stitching_start_date here if added to the model
          break;
        case OrderStatus.completed:
          updateData['completed_date'] = DateTime.now().toIso8601String();
          break;
        case OrderStatus.readyForPickup:
          updateData['pickup_date'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      await _supabase.from('orders').update(updateData).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> updateOrderPaymentStatus(String orderId, PaymentStatus paymentStatus) async {
    try {
      await _supabase.from('orders').update({
        'payment_status': paymentStatus.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  Future<void> addOrderReview(String orderId, double rating, String review) async {
    try {
      await _supabase.from('orders').update({
        'rating': rating,
        'review': review,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      final orderData = await _supabase.from('orders').select().eq('id', orderId).single();
      final order = OrderModel.fromMap(orderData);
      
      final String reviewId = _uuid.v4();
      final ReviewModel reviewModel = ReviewModel(
        id: reviewId,
        orderId: orderId,
        tailorId: order.tailorId,
        customerId: order.customerId,
        customerName: order.customerName,
        rating: rating,
        comment: review,
        images: const [],
        createdAt: DateTime.now(),
      );

      await _supabase.from('reviews').insert(reviewModel.toMap());
      await _updateTailorRating(order.tailorId);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  Future<void> _updateTailorRating(String tailorId) async {
    try {
      final List<dynamic> reviews = await _supabase
          .from('reviews')
          .select('rating')
          .eq('tailor_id', tailorId);

      if (reviews.isNotEmpty) {
        double totalRating = reviews.fold(0, (sum, item) => sum + (item['rating'] as num).toDouble());
        final double averageRating = totalRating / reviews.length;

        await _supabase.from('tailors').update({
          'rating': averageRating,
          'total_reviews': reviews.length,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', tailorId);
      }
    } catch (e) {
      debugPrint('Error updating tailor rating: $e');
    }
  }

  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    try {
      final List<dynamic> data = await _supabase
          .from('orders')
          .select()
          .eq('status', status.toString().split('.').last)
          .order('created_at', ascending: false);

      return data.map((e) => OrderModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by status: $e');
    }
  }

  Future<void> updateOrderDeliveryDate(String orderId, DateTime deliveryDate) async {
    try {
      await _supabase.from('orders').update({
        'delivery_date': deliveryDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update delivery date: $e');
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _supabase.from('orders').update({
        'status': OrderStatus.cancelled.toString().split('.').last,
        'notes': reason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _supabase.from('orders').delete().eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to delete order permanently: $e');
    }
  }
}




