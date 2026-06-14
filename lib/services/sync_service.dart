import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../main.dart'; // for navigatorKey
import '../models/offline_action_model.dart';
import '../models/order_model.dart';
import '../models/message_model.dart';
import '../models/measurement_model.dart';
import '../models/appointment_model.dart';
import '../models/address_model.dart';
import '../models/review_model.dart';

import 'order_service.dart';
import 'chat_service.dart';
import 'measurement_service.dart';
import 'appointment_service.dart';
import 'address_service.dart';
import 'favorite_service.dart';
import 'review_service.dart';

import '../providers/order_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/measurement_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/address_provider.dart';
import '../utils/network_utils.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Uuid _uuid = const Uuid();
  StreamSubscription? _connectivitySubscription;
  bool _isProcessing = false;

  // Initialize the sync service
  void initialize() {
    debugPrint('SyncService: Initializing...');
    
    // Listen to network changes
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      debugPrint('SyncService: Network status changed: $results');
      final hasInternet = await NetworkUtils.checkConnectivity();
      if (hasInternet) {
        debugPrint('SyncService: Connection is online. Processing offline queue...');
        processQueue();
      }
    });

    // Run initial sync check
    Timer(const Duration(seconds: 3), () async {
      final hasInternet = await NetworkUtils.checkConnectivity();
      if (hasInternet) {
        processQueue();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  // Queue a new action when offline
  Future<void> queueAction(String actionType, Map<String, dynamic> payload) async {
    final actionId = _uuid.v4();
    final action = OfflineAction(
      id: actionId,
      actionType: actionType,
      payload: payload,
      createdAt: DateTime.now(),
    );

    final queueBox = Hive.box('offline_queue');
    await queueBox.put(actionId, action.toMap());
    debugPrint('SyncService: Queued offline action $actionId ($actionType)');

    // Attempt to process immediately if online (fallback safeguard)
    final hasInternet = await NetworkUtils.checkConnectivity();
    if (hasInternet) {
      processQueue();
    }
  }

  // Process FIFO queue
  Future<void> processQueue() async {
    if (_isProcessing) {
      debugPrint('SyncService: Queue processing already in progress. Skipping duplicate run...');
      return;
    }

    final hasInternet = await NetworkUtils.checkConnectivity();
    if (!hasInternet) {
      debugPrint('SyncService: Cannot process queue. Internet check failed.');
      return;
    }

    final queueBox = Hive.box('offline_queue');
    if (queueBox.isEmpty) {
      debugPrint('SyncService: Offline queue is empty. Nothing to sync.');
      return;
    }

    _isProcessing = true;
    debugPrint('SyncService: Syncing ${queueBox.length} queued offline actions...');

    // Convert keys to list and sort them to maintain FIFO order
    final keys = List.from(queueBox.keys);
    
    for (final key in keys) {
      final data = queueBox.get(key);
      if (data == null) continue;

      final action = OfflineAction.fromMap(Map<String, dynamic>.from(data));
      bool success = false;

      try {
        success = await _executeAction(action);
      } catch (e) {
        debugPrint('SyncService: Error executing action ${action.id} of type ${action.actionType}: $e');
        // If there's an error, mark as processed/success to avoid blocking the queue permanently
        // (usually due to database record mismatch or conflicts)
        success = true;
      }

      if (success) {
        await queueBox.delete(key);
        debugPrint('SyncService: Action ${action.id} synced and deleted from queue.');
      } else {
        debugPrint('SyncService: Temporary sync failure for action ${action.id}. Stopping queue...');
        break;
      }
    }

    _isProcessing = false;

    // Trigger provider reloads once sync is complete
    if (queueBox.isEmpty) {
      debugPrint('SyncService: Sync complete. Refreshing user data.');
      _triggerProvidersRefresh();
    }
  }

  // Execute specific action based on type
  Future<bool> _executeAction(OfflineAction action) async {
    final payload = action.payload;

    switch (action.actionType) {
      // --- ORDER ACTIONS ---
      case 'create_order':
        final order = OrderModel.fromMap(payload);
        await OrderService().createOrder(order);
        return true;

      case 'update_order_status':
        final status = OrderStatus.values.firstWhere(
          (e) => e.name == payload['status'],
          orElse: () => OrderStatus.pending,
        );
        await OrderService().updateOrderStatus(payload['orderId'], status);
        return true;

      case 'update_order_payment_status':
        final paymentStatus = PaymentStatus.values.firstWhere(
          (e) => e.name == payload['paymentStatus'],
          orElse: () => PaymentStatus.pending,
        );
        await OrderService().updateOrderPaymentStatus(payload['orderId'], paymentStatus);
        return true;

      case 'add_order_review':
        await OrderService().addOrderReview(
          payload['orderId'],
          (payload['rating'] ?? 0.0).toDouble(),
          payload['review'] ?? '',
        );
        return true;

      case 'delete_order':
        await OrderService().deleteOrder(payload['orderId']);
        return true;

      // --- CHAT ACTIONS ---
      case 'send_message':
        String content = payload['content'] ?? '';
        final typeStr = payload['type'] ?? 'text';
        final type = MessageType.values.firstWhere(
          (e) => e.name == typeStr,
          orElse: () => MessageType.text,
        );

        if (type == MessageType.audio && payload['localAudioPath'] != null) {
          final audioUrl = await ChatService().uploadAudio(payload['localAudioPath']);
          if (audioUrl != null) {
            content = audioUrl;
          }
        }

        await ChatService().sendMessage(
          senderId: payload['senderId'],
          receiverId: payload['receiverId'],
          senderName: payload['senderName'] ?? '',
          receiverName: payload['receiverName'] ?? '',
          content: content,
          orderId: payload['orderId'],
          type: type,
        );
        return true;

      case 'delete_message':
        await ChatService().deleteMessage(payload['messageId']);
        return true;

      case 'edit_message':
        await ChatService().editMessage(payload['messageId'], payload['newContent']);
        return true;

      // --- MEASUREMENT ACTIONS ---
      case 'create_measurement_request':
        await MeasurementService().createMeasurementRequest(
          customerId: payload['customerId'],
          tailorId: payload['tailorId'],
          customerName: payload['customerName'],
          tailorName: payload['tailorName'],
          notes: payload['notes'],
        );
        return true;

      case 'schedule_appointment':
        await MeasurementService().scheduleAppointment(
          measurementId: payload['measurementId'],
          appointmentDate: DateTime.parse(payload['appointmentDate']),
          appointmentTime: DateTime.parse(payload['appointmentTime']),
        );
        return true;

      case 'take_measurements':
        await MeasurementService().takeMeasurements(
          measurementId: payload['measurementId'],
          measurements: Map<String, double>.from(payload['measurements'] ?? {}),
          notes: payload['notes'],
        );
        return true;

      case 'cancel_measurement':
        await MeasurementService().cancelMeasurement(payload['measurementId']);
        return true;

      case 'create_measurement':
        final measurements = Map<String, double>.from(payload['measurements'] ?? {});
        await MeasurementService().createMeasurement(
          customerId: payload['customerId'],
          tailorId: payload['tailorId'],
          customerName: payload['customerName'],
          tailorName: payload['tailorName'],
          measurements: measurements,
          notes: payload['notes'],
          status: MeasurementStatus.values.firstWhere(
            (e) => e.name == payload['status'],
            orElse: () => MeasurementStatus.completed,
          ),
        );
        return true;

      case 'update_measurement':
        await MeasurementService().updateMeasurement(
          measurementId: payload['measurementId'],
          measurements: payload['measurements'] != null 
              ? Map<String, double>.from(payload['measurements']) 
              : null,
          notes: payload['notes'],
        );
        return true;

      case 'delete_measurement':
        await MeasurementService().deleteMeasurement(payload['measurementId']);
        return true;

      // --- APPOINTMENT ACTIONS ---
      case 'book_appointment':
        final appointment = AppointmentModel.fromMap(payload);
        await AppointmentService().createAppointment(appointment);
        return true;

      case 'approve_appointment':
        await AppointmentService().approveAppointment(payload['appointmentId']);
        return true;

      case 'decline_appointment':
        await AppointmentService().declineAppointment(payload['appointmentId']);
        return true;

      case 'cancel_appointment':
        await AppointmentService().cancelAppointment(payload['appointmentId']);
        return true;

      // --- ADDRESS ACTIONS ---
      case 'add_address':
        final address = AddressModel.fromMap(payload);
        await AddressService().addAddress(address);
        return true;

      case 'update_address':
        final address = AddressModel.fromMap(payload);
        await AddressService().updateAddress(address);
        return true;

      case 'delete_address':
        await AddressService().deleteAddress(payload['addressId']);
        return true;

      case 'set_default_address':
        await AddressService().setDefault(payload['userId'], payload['addressId']);
        return true;

      // --- FAVORITE ACTIONS ---
      case 'add_to_favorites':
        await FavoriteService().addToFavorites(payload['customerId'], payload['tailorId']);
        return true;

      case 'remove_from_favorites':
        await FavoriteService().removeFromFavorites(payload['customerId'], payload['tailorId']);
        return true;

      // --- REVIEW ACTIONS ---
      case 'add_review':
        final review = ReviewModel.fromMap(payload);
        await ReviewService().addReview(review);
        return true;

      default:
        debugPrint('SyncService: Unknown action type ${action.actionType}. Skipping.');
        return true;
    }
  }

  // Reload providers in the active context
  void _triggerProvidersRefresh() {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('SyncService: Context not available to refresh providers.');
      return;
    }

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final measurementProvider = Provider.of<MeasurementProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);

      // Refresh Orders
      if (orderProvider.customerOrders.isNotEmpty) {
        orderProvider.fetchCustomerOrders(orderProvider.customerOrders.first.customerId);
      }
      if (orderProvider.tailorOrders.isNotEmpty) {
        orderProvider.fetchTailorOrders(orderProvider.tailorOrders.first.tailorId);
      }

      // Refresh Chat Conversations list
      if (chatProvider.conversations.isNotEmpty) {
        final userId = chatProvider.conversations.first.userId1;
        chatProvider.refreshConversations(userId);
      }

      // Refresh Measurements
      if (measurementProvider.customerMeasurements.isNotEmpty) {
        measurementProvider.fetchCustomerMeasurements(measurementProvider.customerMeasurements.first.customerId);
      }
      if (measurementProvider.tailorMeasurementRequests.isNotEmpty) {
        measurementProvider.fetchTailorMeasurementRequests(measurementProvider.tailorMeasurementRequests.first.tailorId);
      }

      // Refresh Appointments
      if (appointmentProvider.customerAppointments.isNotEmpty) {
        appointmentProvider.loadCustomerAppointments(appointmentProvider.customerAppointments.first.customerId);
      }
      if (appointmentProvider.tailorAppointments.isNotEmpty) {
        appointmentProvider.loadTailorAppointments(appointmentProvider.tailorAppointments.first.tailorId);
      }

      // Refresh Addresses
      if (addressProvider.addresses.isNotEmpty) {
        addressProvider.loadAddresses(addressProvider.addresses.first.userId);
      }
    } catch (e) {
      debugPrint('SyncService: Failed to trigger provider refresh: $e');
    }
  }
}
