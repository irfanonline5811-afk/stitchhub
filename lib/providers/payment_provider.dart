import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  
  bool _isLoading = false;
  String? _error;
  List<PaymentModel> _paymentHistory = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PaymentModel> get paymentHistory => _paymentHistory;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load payment history for a customer
  Future<void> loadPaymentHistory(String customerId) async {
    try {
      _setLoading(true);
      _setError(null);
      _paymentHistory = await _paymentService.getPaymentHistory(customerId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get payment by order ID
  Future<PaymentModel?> getPaymentByOrderId(String orderId) async {
    try {
      return await _paymentService.getPaymentByOrderId(orderId);
    } catch (e) {
      debugPrint('Error getting payment: $e');
      return null;
    }
  }

  // Process refund
  Future<Map<String, dynamic>> processRefund({
    required String paymentId,
    double? amount,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      final result = await _paymentService.processRefund(
        transactionId: paymentId,
        amount: amount ?? 0.0,
      );
      _setLoading(false);
      
      if (result['success'] == true) {
        // Reload payment history if needed
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}













