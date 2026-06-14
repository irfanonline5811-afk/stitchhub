import 'package:flutter/material.dart';
import 'dart:async';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../utils/network_utils.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  final List<OrderModel> _orders = [];
  List<OrderModel> _customerOrders = [];
  List<OrderModel> _tailorOrders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  List<OrderModel> get customerOrders => _customerOrders;
  List<OrderModel> get tailorOrders => _tailorOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      final createdOrder = await _orderService.createOrder(order);
      if (createdOrder != null) {
        _orders.add(createdOrder);
        _customerOrders.add(createdOrder);
        
        // Cache results
        await LocalStorageService().saveData(
            'customer_orders', _customerOrders.map((e) => e.toMap()).toList(), userId: order.customerId);
        
        notifyListeners();
      }
      _setLoading(false);
      return createdOrder;
    } catch (e) {
      debugPrint('OrderProvider: createOrder failed, queueing offline. Error: $e');
      
      // Optimistic Update
      _orders.add(order);
      _customerOrders.add(order);
      
      // Save to local cache
      await LocalStorageService().saveData(
          'customer_orders', _customerOrders.map((e) => e.toMap()).toList(), userId: order.customerId);
      
      // Queue offline sync
      await SyncService().queueAction('create_order', order.toMap());
      
      _setError('Working offline. Order queued for sync.');
      _setLoading(false);
      return order;
    }
  }

  Future<void> fetchCustomerOrders(String customerId) async {
    if (customerId.isEmpty || customerId == 'null') {
      _setError('Invalid Customer ID');
      _setLoading(false);
      return;
    }

    // Prevent duplicate calls if already loading
    if (_isLoading) {
      debugPrint('OrderProvider: fetchCustomerOrders already in progress, skipping...');
      return;
    }

    // Safety timeout to prevent infinite loading
    bool timedOut = false;
    final timeoutTimer = Timer(const Duration(seconds: 12), () {
      if (_isLoading) {
        timedOut = true;
        debugPrint('OrderProvider: fetchCustomerOrders FORCE RESET after 12s');
        _setLoading(false);
        if (_customerOrders.isEmpty) {
          _setError('Timed out. Tap refresh to try again.');
        }
      }
    });

    try {
      _setLoading(true);
      _setError(null);
      debugPrint('OrderProvider: Fetching customer orders for $customerId');

      final orders = await _orderService.getCustomerOrders(customerId);
      
      if (timedOut) return; // Don't update if we already timed out
      
      _customerOrders = orders;
      debugPrint('OrderProvider: Successfully fetched ${orders.length} customer orders');
      
      // Cache results with userId for privacy
      await LocalStorageService().saveData(
          'customer_orders', _customerOrders.map((e) => e.toMap()).toList(), userId: customerId);
    } catch (e) {
      if (timedOut) return;
      debugPrint('OrderProvider: Customer Fetch error, checking cache. Error: $e');
      // Load from cache if offline
      try {
        final cachedData = LocalStorageService().getData('customer_orders', userId: customerId);
        if (cachedData != null && cachedData is List) {
          _customerOrders = cachedData.map((e) => OrderModel.fromMap(e)).toList();
          _setError('Working offline. Showing cached orders.');
        } else {
          _setError(e.toString());
        }
      } catch (cacheError) {
        debugPrint('OrderProvider: Cache parsing error: $cacheError');
        _setError('Failed to load orders: $e');
      }
    } finally {
      timeoutTimer.cancel();
      if (!timedOut) {
        _setLoading(false);
      }
    }
  }

  Future<void> fetchTailorOrders(String tailorId) async {
    if (tailorId.isEmpty || tailorId == 'null') {
      _setError('Invalid Tailor ID');
      _setLoading(false);
      return;
    }

    // Prevent duplicate calls if already loading
    if (_isLoading) {
      debugPrint('OrderProvider: fetchTailorOrders already in progress, skipping...');
      return;
    }

    // Safety timeout to prevent infinite loading
    bool timedOut = false;
    final timeoutTimer = Timer(const Duration(seconds: 12), () {
      if (_isLoading) {
        timedOut = true;
        debugPrint('OrderProvider: fetchTailorOrders FORCE RESET after 12s');
        _setLoading(false);
        if (_tailorOrders.isEmpty) {
          _setError('Timed out. Tap refresh to try again.');
        }
      }
    });

    try {
      _setLoading(true);
      _setError(null);
      debugPrint('OrderProvider: Fetching tailor orders for $tailorId');

      final orders = await _orderService.getTailorOrders(tailorId);
      
      if (timedOut) return;

      _tailorOrders = orders;
      debugPrint('OrderProvider: Successfully fetched ${orders.length} tailor orders');
      
      // Cache results with userId for privacy
      await LocalStorageService().saveData(
          'tailor_orders', _tailorOrders.map((e) => e.toMap()).toList(), userId: tailorId);
    } catch (e) {
      if (timedOut) return;
      debugPrint('OrderProvider: Tailor Fetch error, checking cache. Error: $e');
      // Load from cache if offline
      try {
        final cachedData = LocalStorageService().getData('tailor_orders', userId: tailorId);
        if (cachedData != null && cachedData is List) {
          _tailorOrders = cachedData.map((e) => OrderModel.fromMap(e)).toList();
          _setError('Working offline. Showing cached orders.');
        } else {
          _setError(e.toString());
        }
      } catch (cacheError) {
        debugPrint('OrderProvider: Cache parsing error: $cacheError');
        _setError('Failed to load orders: $e');
      }
    } finally {
      timeoutTimer.cancel();
      if (!timedOut) {
        _setLoading(false);
      }
    }
  }

  // Emergency method to clear stuck loading
  void forceResetLoading() {
    debugPrint('OrderProvider: Manual FORCE RESET triggered');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveAllCaches() async {
    try {
      if (_customerOrders.isNotEmpty) {
        final custId = _customerOrders.first.customerId;
        await LocalStorageService().saveData(
            'customer_orders', _customerOrders.map((e) => e.toMap()).toList(), userId: custId);
      }
      if (_tailorOrders.isNotEmpty) {
        final tailorId = _tailorOrders.first.tailorId;
        await LocalStorageService().saveData(
            'tailor_orders', _tailorOrders.map((e) => e.toMap()).toList(), userId: tailorId);
      }
    } catch (e) {
      debugPrint('OrderProvider: Cache save failed: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _orderService.updateOrderStatus(orderId, status);
      
      // Update local state
      _updateOrderInList(_orders, orderId, status);
      _updateOrderInList(_customerOrders, orderId, status);
      _updateOrderInList(_tailorOrders, orderId, status);
      
      // Cache results
      await _saveAllCaches();
      
      _setLoading(false);
    } catch (e) {
      debugPrint('OrderProvider: updateOrderStatus failed, queueing offline. Error: $e');
      
      // Optimistic update
      _updateOrderInList(_orders, orderId, status);
      _updateOrderInList(_customerOrders, orderId, status);
      _updateOrderInList(_tailorOrders, orderId, status);
      
      // Local Cache Save
      await _saveAllCaches();

      // Queue offline sync
      await SyncService().queueAction('update_order_status', {
        'orderId': orderId,
        'status': status.name,
      });

      _setError('Working offline. Order status update queued.');
      _setLoading(false);
    }
  }

  void _updateOrderInList(List<OrderModel> orders, String orderId, OrderStatus status) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      orders[index] = orders[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> updateOrderPaymentStatus(String orderId, PaymentStatus paymentStatus) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _orderService.updateOrderPaymentStatus(orderId, paymentStatus);
      
      // Update local state
      _updateOrderPaymentInList(_orders, orderId, paymentStatus);
      _updateOrderPaymentInList(_customerOrders, orderId, paymentStatus);
      _updateOrderPaymentInList(_tailorOrders, orderId, paymentStatus);
      
      // Cache results
      await _saveAllCaches();
      
      _setLoading(false);
    } catch (e) {
      debugPrint('OrderProvider: updateOrderPaymentStatus failed, queueing offline. Error: $e');
      
      // Optimistic update
      _updateOrderPaymentInList(_orders, orderId, paymentStatus);
      _updateOrderPaymentInList(_customerOrders, orderId, paymentStatus);
      _updateOrderPaymentInList(_tailorOrders, orderId, paymentStatus);

      // Local Cache Save
      await _saveAllCaches();

      // Queue offline sync
      await SyncService().queueAction('update_order_payment_status', {
        'orderId': orderId,
        'paymentStatus': paymentStatus.name,
      });

      _setError('Working offline. Payment status update queued.');
      _setLoading(false);
    }
  }

  void _updateOrderPaymentInList(List<OrderModel> orders, String orderId, PaymentStatus paymentStatus) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      orders[index] = orders[index].copyWith(
        paymentStatus: paymentStatus,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> addOrderReview(String orderId, double rating, String review) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _orderService.addOrderReview(orderId, rating, review);
      
      // Update local state
      _updateOrderReviewInList(_orders, orderId, rating, review);
      _updateOrderReviewInList(_customerOrders, orderId, rating, review);
      _updateOrderReviewInList(_tailorOrders, orderId, rating, review);
      
      // Cache results
      await _saveAllCaches();
      
      _setLoading(false);
    } catch (e) {
      debugPrint('OrderProvider: addOrderReview failed, queueing offline. Error: $e');

      // Optimistic update
      _updateOrderReviewInList(_orders, orderId, rating, review);
      _updateOrderReviewInList(_customerOrders, orderId, rating, review);
      _updateOrderReviewInList(_tailorOrders, orderId, rating, review);

      // Local Cache Save
      await _saveAllCaches();

      // Queue offline sync
      await SyncService().queueAction('add_order_review', {
        'orderId': orderId,
        'rating': rating,
        'review': review,
      });

      _setError('Working offline. Order review queued.');
      _setLoading(false);
    }
  }

  void _updateOrderReviewInList(List<OrderModel> orders, String orderId, double rating, String review) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      orders[index] = orders[index].copyWith(
        rating: rating,
        review: review,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      _setLoading(true);
      _setError(null);

      final order = await _orderService.getOrderById(orderId);
      _setLoading(false);
      return order;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _orderService.deleteOrder(orderId);
      
      // Remove from local lists
      _orders.removeWhere((order) => order.id == orderId);
      _customerOrders.removeWhere((order) => order.id == orderId);
      _tailorOrders.removeWhere((order) => order.id == orderId);
      
      // Cache results
      await _saveAllCaches();
      
      _setLoading(false);
    } catch (e) {
      debugPrint('OrderProvider: deleteOrder failed, queueing offline. Error: $e');

      // Optimistic delete
      _orders.removeWhere((order) => order.id == orderId);
      _customerOrders.removeWhere((order) => order.id == orderId);
      _tailorOrders.removeWhere((order) => order.id == orderId);

      // Local Cache Save
      await _saveAllCaches();

      // Queue offline sync
      await SyncService().queueAction('delete_order', {
        'orderId': orderId,
      });

      _setError('Working offline. Order deletion queued.');
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
}



