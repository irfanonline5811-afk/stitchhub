import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import 'package:uuid/uuid.dart';

class PaymentService {
  final _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();
  
  
  // Save payment record to Supabase
  Future<void> savePayment({
    required String orderId,
    required String customerId,
    required double amount,
    String? transactionId,
    String? paymentMethod,
    PaymentTransactionStatus status = PaymentTransactionStatus.pending,
    String? failureReason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final paymentId = _uuid.v4();
      final payment = PaymentModel(
        id: paymentId,
        orderId: orderId,
        customerId: customerId,
        transactionId: transactionId,
        paymentMethod: paymentMethod,
        amount: amount,
        status: status,
        failureReason: failureReason,
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _supabase.from('payments').insert(payment.toMap());

      // Update the order with payment status
      await _supabase.from('orders').update({
        'payment_status': status == PaymentTransactionStatus.succeeded
            ? 'paid'
            : status == PaymentTransactionStatus.refunded
                ? 'refunded'
                : 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      debugPrint('Payment saved: $paymentId');
    } catch (e) {
      debugPrint('Error saving payment: $e');
      rethrow;
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus({
    required String paymentId,
    required PaymentTransactionStatus status,
    String? failureReason,
  }) async {
    try {
      await _supabase.from('payments').update({
        'status': status.toString().split('.').last,
        'failure_reason': failureReason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', paymentId);

      final paymentData = await _supabase.from('payments').select().eq('id', paymentId).single();
      final orderId = paymentData['order_id'];
      
      if (orderId != null) {
        await _supabase.from('orders').update({
          'payment_status': status == PaymentTransactionStatus.succeeded
              ? 'paid'
              : status == PaymentTransactionStatus.refunded
                  ? 'refunded'
                  : 'pending',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', orderId);
      }
    } catch (e) {
      debugPrint('Error updating payment status: $e');
      rethrow;
    }
  }

  // Get payment by order ID
  Future<PaymentModel?> getPaymentByOrderId(String orderId) async {
    try {
      final data = await _supabase
          .from('payments')
          .select()
          .eq('order_id', orderId)
          .maybeSingle();

      if (data != null) {
        return PaymentModel.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting payment: $e');
      return null;
    }
  }

  // Get payment history for a customer
  Future<List<PaymentModel>> getPaymentHistory(String customerId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('payments')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return data.map((e) => PaymentModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error getting payment history: $e');
      return [];
    }
  }

  // Process refund (Mock for local wallets)
  Future<Map<String, dynamic>> processRefund({
    required String transactionId,
    required double amount,
  }) async {
    try {
      await _supabase.from('payments').update({
        'status': 'refunded',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('transaction_id', transactionId);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
