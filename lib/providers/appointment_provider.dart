import 'package:flutter/material.dart';
import 'dart:async';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../utils/network_utils.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _service = AppointmentService();

  bool _isLoading = false;
  String? _error;
  List<AppointmentModel> _customerAppointments = [];
  List<AppointmentModel> _tailorAppointments = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AppointmentModel> get customerAppointments => _customerAppointments;
  List<AppointmentModel> get tailorAppointments => _tailorAppointments;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  Future<void> _saveAllCaches() async {
    try {
      if (_customerAppointments.isNotEmpty) {
        final custId = _customerAppointments.first.customerId;
        await LocalStorageService().saveData(
            'customer_appointments', _customerAppointments.map((e) => e.toMap()).toList(), userId: custId);
      }
      if (_tailorAppointments.isNotEmpty) {
        final tailorId = _tailorAppointments.first.tailorId;
        await LocalStorageService().saveData(
            'tailor_appointments', _tailorAppointments.map((e) => e.toMap()).toList(), userId: tailorId);
      }
    } catch (e) {
      debugPrint('AppointmentProvider: Cache save failed: $e');
    }
  }

  Future<bool> bookAppointment(AppointmentModel appointment) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      final created = await _service.createAppointment(appointment);
      _customerAppointments.add(created);
      await _saveAllCaches();
      
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('AppointmentProvider: bookAppointment failed, queueing offline. Error: $e');

      // Optimistic update
      _customerAppointments.add(appointment);
      notifyListeners();
      await _saveAllCaches();

      // Queue action
      await SyncService().queueAction('book_appointment', appointment.toMap());

      _setError('Working offline. Appointment booking queued.');
      _setLoading(false);
      return true;
    }
  }

  Stream<List<AppointmentModel>> getCustomerAppointmentsStream(String customerId) {
    return _service.getCustomerAppointmentsStream(customerId);
  }

  Stream<List<AppointmentModel>> getTailorAppointmentsStream(String tailorId) {
    return _service.getTailorAppointmentsStream(tailorId);
  }

  Future<void> loadCustomerAppointments(String customerId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final appointments = await _service.getCustomerAppointments(customerId);
      _customerAppointments = appointments;
      
      // Cache results
      await LocalStorageService().saveData(
          'customer_appointments', _customerAppointments.map((e) => e.toMap()).toList(), userId: customerId);
    } catch (e) {
      debugPrint('AppointmentProvider: loadCustomerAppointments failed, checking cache. Error: $e');
      final cachedData = LocalStorageService().getData('customer_appointments', userId: customerId);
      if (cachedData != null && cachedData is List) {
        _customerAppointments = cachedData.map((e) => AppointmentModel.fromMap(e)).toList();
        _setError('Working offline. Showing cached appointments.');
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTailorAppointments(String tailorId) async {
    try {
      _setLoading(true);
      _setError(null);

      final appointments = await _service.getTailorAppointments(tailorId);
      _tailorAppointments = appointments;

      // Cache results
      await LocalStorageService().saveData(
          'tailor_appointments', _tailorAppointments.map((e) => e.toMap()).toList(), userId: tailorId);
    } catch (e) {
      debugPrint('AppointmentProvider: loadTailorAppointments failed, checking cache. Error: $e');
      final cachedData = LocalStorageService().getData('tailor_appointments', userId: tailorId);
      if (cachedData != null && cachedData is List) {
        _tailorAppointments = cachedData.map((e) => AppointmentModel.fromMap(e)).toList();
        _setError('Working offline. Showing cached appointments.');
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  void _updateLocalStatus(String appointmentId, AppointmentStatus status) {
    final custIndex = _customerAppointments.indexWhere((a) => a.id == appointmentId);
    if (custIndex != -1) {
      _customerAppointments[custIndex] = _customerAppointments[custIndex].copyWith(status: status);
    }

    final tailorIndex = _tailorAppointments.indexWhere((a) => a.id == appointmentId);
    if (tailorIndex != -1) {
      _tailorAppointments[tailorIndex] = _tailorAppointments[tailorIndex].copyWith(status: status);
    }
    notifyListeners();
  }

  Future<void> approve(String appointmentId) async {
    try {
      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _service.approveAppointment(appointmentId);
      _updateLocalStatus(appointmentId, AppointmentStatus.approved);
      await _saveAllCaches();
    } catch (e) {
      debugPrint('AppointmentProvider: approve failed, queueing offline. Error: $e');

      // Optimistic update
      _updateLocalStatus(appointmentId, AppointmentStatus.approved);
      await _saveAllCaches();

      // Queue action
      await SyncService().queueAction('approve_appointment', {
        'appointmentId': appointmentId,
      });
      _setError('Working offline. Approval queued.');
    }
  }

  Future<void> decline(String appointmentId) async {
    try {
      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _service.declineAppointment(appointmentId);
      _updateLocalStatus(appointmentId, AppointmentStatus.declined);
      await _saveAllCaches();
    } catch (e) {
      debugPrint('AppointmentProvider: decline failed, queueing offline. Error: $e');

      // Optimistic update
      _updateLocalStatus(appointmentId, AppointmentStatus.declined);
      await _saveAllCaches();

      // Queue action
      await SyncService().queueAction('decline_appointment', {
        'appointmentId': appointmentId,
      });
      _setError('Working offline. Decline queued.');
    }
  }

  Future<void> cancel(String appointmentId) async {
    try {
      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _service.cancelAppointment(appointmentId);
      _updateLocalStatus(appointmentId, AppointmentStatus.cancelled);
      await _saveAllCaches();
    } catch (e) {
      debugPrint('AppointmentProvider: cancel failed, queueing offline. Error: $e');

      // Optimistic update
      _updateLocalStatus(appointmentId, AppointmentStatus.cancelled);
      await _saveAllCaches();

      // Queue action
      await SyncService().queueAction('cancel_appointment', {
        'appointmentId': appointmentId,
      });
      _setError('Working offline. Cancellation queued.');
    }
  }
}
