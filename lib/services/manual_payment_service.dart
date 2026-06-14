import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/manual_payment_model.dart';
import 'package:uuid/uuid.dart';

class ManualPaymentService {
  final _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // Upload receipt screenshot to 'payment-proofs' storage bucket
  Future<String?> uploadPaymentScreenshot({
    required String orderId,
    required dynamic imageFile, // Supports File (mobile)
    Uint8List? imageBytes,      // Supports Web bytes
    String fileExtension = 'jpg',
  }) async {
    try {
      final String path = 'proofs/$orderId-${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      
      if (kIsWeb) {
        if (imageBytes == null) throw Exception('Image bytes are null on web platform.');
        
        // Supabase storage web-friendly upload using uploadBinary
        await _supabase.storage.from('payment-proofs').uploadBinary(
          path,
          imageBytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExtension',
            upsert: true,
          ),
        );
      } else {
        final File file = imageFile as File;
        await _supabase.storage.from('payment-proofs').upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
      }
      
      final String publicUrl = _supabase.storage.from('payment-proofs').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('ManualPaymentService: Storage upload failed: $e');
      throw Exception('Failed to upload receipt screenshot: $e');
    }
  }

  // Submit manual payment proof
  Future<ManualPaymentModel> submitManualPayment({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required double amount,
    required String paymentMethod,
    String? transactionId,
    String? screenshotUrl,
  }) async {
    try {
      final String paymentId = _uuid.v4();
      final payment = ManualPaymentModel(
        id: paymentId,
        orderId: orderId,
        customerName: customerName,
        customerPhone: customerPhone,
        amount: amount,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        screenshotUrl: screenshotUrl,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 1. Insert manual payment record
      await _supabase.from('manual_payments').insert(payment.toMap());

      // 2. Update order payment status to 'pending' in database
      await _supabase.from('orders').update({
        'payment_status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      return payment;
    } catch (e) {
      debugPrint('ManualPaymentService: Submission failed: $e');
      throw Exception('Failed to submit manual payment: $e');
    }
  }

  // Get manual payment details by Order ID
  Future<ManualPaymentModel?> getPaymentByOrderId(String orderId) async {
    try {
      final data = await _supabase
          .from('manual_payments')
          .select()
          .eq('order_id', orderId)
          .maybeSingle();

      if (data != null) {
        return ManualPaymentModel.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('ManualPaymentService: Get payment by orderId error: $e');
      return null;
    }
  }

  // Get all payments for a specific tailor
  Future<List<ManualPaymentModel>> getTailorManualPayments(String tailorId) async {
    try {
      // Select manual_payments joined with orders where tailor_id matches
      final List<dynamic> data = await _supabase
          .from('manual_payments')
          .select('*, orders!inner(tailor_id)')
          .eq('orders.tailor_id', tailorId)
          .order('created_at', ascending: false);

      return data.map((e) => ManualPaymentModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('ManualPaymentService: Get tailor payments error: $e');
      return [];
    }
  }

  // Update payment status (Approve/Reject)
  Future<void> updatePaymentStatus({
    required String paymentId,
    required String orderId,
    required String status, // 'approved', 'rejected'
  }) async {
    try {
      // 1. Update status in manual_payments table
      await _supabase.from('manual_payments').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', paymentId);

      // 2. Update status in orders table
      String orderPaymentStatus = 'pending';
      if (status == 'approved') {
        orderPaymentStatus = 'paid';
      } else if (status == 'rejected') {
        orderPaymentStatus = 'failed';
      }

      await _supabase.from('orders').update({
        'payment_status': orderPaymentStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      debugPrint('ManualPaymentService: Payment $paymentId status updated to $status');
    } catch (e) {
      debugPrint('ManualPaymentService: Update status error: $e');
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Listen to real-time updates for a specific payment
  RealtimeChannel listenToPaymentStatus(
    String paymentId,
    void Function(ManualPaymentModel) onUpdate,
  ) {
    return _supabase
        .channel('manual_payment_status:$paymentId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'manual_payments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: paymentId,
          ),
          callback: (payload) {
            debugPrint('ManualPaymentService: Real-time update detected.');
            final updatedPayment = ManualPaymentModel.fromMap(payload.newRecord);
            onUpdate(updatedPayment);
          },
        )
        .subscribe();
  }
}
