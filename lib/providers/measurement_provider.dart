import 'package:flutter/material.dart';
import 'dart:async';
import '../models/measurement_model.dart';
import '../services/measurement_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../utils/network_utils.dart';

class MeasurementProvider with ChangeNotifier {
  final MeasurementService _measurementService = MeasurementService();
  List<MeasurementModel> _customerMeasurements = [];
  List<MeasurementModel> _tailorMeasurementRequests = [];
  bool _isLoading = false;
  String? _error;

  List<MeasurementModel> get customerMeasurements => _customerMeasurements;
  List<MeasurementModel> get tailorMeasurementRequests => _tailorMeasurementRequests;
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

  Future<void> _saveAllCaches() async {
    try {
      if (_customerMeasurements.isNotEmpty) {
        final custId = _customerMeasurements.first.customerId;
        await LocalStorageService().saveData(
            'customer_measurements', _customerMeasurements.map((e) => e.toMap()).toList(), userId: custId);
      }
      if (_tailorMeasurementRequests.isNotEmpty) {
        final tailorId = _tailorMeasurementRequests.first.tailorId;
        await LocalStorageService().saveData(
            'tailor_measurement_requests', _tailorMeasurementRequests.map((e) => e.toMap()).toList(), userId: tailorId);
        await LocalStorageService().saveData(
            'all_tailor_measurements', _tailorMeasurementRequests.map((e) => e.toMap()).toList(), userId: tailorId);
      }
    } catch (e) {
      debugPrint('MeasurementProvider: Cache save failed: $e');
    }
  }

  Future<bool> createMeasurementRequest({
    required String customerId,
    required String tailorId,
    required String customerName,
    required String tailorName,
    String? notes,
  }) async {
    final tempId = 'meas_${DateTime.now().millisecondsSinceEpoch}';
    final tempMeasurement = MeasurementModel(
      id: tempId,
      customerId: customerId,
      tailorId: tailorId,
      customerName: customerName,
      tailorName: tailorName,
      status: MeasurementStatus.pending,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      final measurement = await _measurementService.createMeasurementRequest(
        customerId: customerId,
        tailorId: tailorId,
        customerName: customerName,
        tailorName: tailorName,
        notes: notes,
      );

      if (measurement != null) {
        _customerMeasurements.insert(0, measurement);
        await _saveAllCaches();
        _setLoading(false);
        return true;
      }
      _setError('Failed to create measurement request');
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('MeasurementProvider: createMeasurementRequest failed, queueing offline. Error: $e');

      // Optimistic update
      _customerMeasurements.insert(0, tempMeasurement);
      notifyListeners();
      await _saveAllCaches();

      // Queue action
      await SyncService().queueAction('create_measurement_request', {
        'customerId': customerId,
        'tailorId': tailorId,
        'customerName': customerName,
        'tailorName': tailorName,
        'notes': notes,
      });

      _setError('Working offline. Measurement request queued.');
      _setLoading(false);
      return true;
    }
  }

  Future<void> fetchCustomerMeasurements(String customerId) async {
    try {
      _setLoading(true);
      _setError(null);

      final measurements = await _measurementService.getCustomerMeasurements(customerId);
      _customerMeasurements = measurements;
      
      // Cache results
      await LocalStorageService().saveData(
          'customer_measurements', _customerMeasurements.map((e) => e.toMap()).toList(), userId: customerId);
    } catch (e) {
      debugPrint('MeasurementProvider: fetchCustomerMeasurements failed, checking cache. Error: $e');
      final cachedData = LocalStorageService().getData('customer_measurements', userId: customerId);
      if (cachedData != null && cachedData is List) {
        _customerMeasurements = cachedData.map((e) => MeasurementModel.fromMap(e)).toList();
        _setError('Working offline. Showing cached measurements.');
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTailorMeasurementRequests(String tailorId) async {
    try {
      _setLoading(true);
      _setError(null);

      final measurements = await _measurementService.getTailorMeasurementRequests(tailorId);
      _tailorMeasurementRequests = measurements;

      // Cache results
      await LocalStorageService().saveData(
          'tailor_measurement_requests', _tailorMeasurementRequests.map((e) => e.toMap()).toList(), userId: tailorId);
    } catch (e) {
      debugPrint('MeasurementProvider: fetchTailorMeasurementRequests failed, checking cache. Error: $e');
      final cachedData = LocalStorageService().getData('tailor_measurement_requests', userId: tailorId);
      if (cachedData != null && cachedData is List) {
        _tailorMeasurementRequests = cachedData.map((e) => MeasurementModel.fromMap(e)).toList();
        _setError('Working offline. Showing cached requests.');
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> scheduleAppointment({
    required String measurementId,
    required DateTime appointmentDate,
    required DateTime appointmentTime,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _measurementService.scheduleAppointment(
        measurementId: measurementId,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
      );

      _updateLocalStatus(measurementId, MeasurementStatus.scheduled, 
          appointmentDate: appointmentDate, appointmentTime: appointmentTime);
      await _saveAllCaches();
      
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('MeasurementProvider: scheduleAppointment failed, queueing offline. Error: $e');

      // Optimistic update
      _updateLocalStatus(measurementId, MeasurementStatus.scheduled, 
          appointmentDate: appointmentDate, appointmentTime: appointmentTime);
      await _saveAllCaches();

      // Queue action
      await SyncService().queueAction('schedule_appointment', {
        'measurementId': measurementId,
        'appointmentDate': appointmentDate.toIso8601String(),
        'appointmentTime': appointmentTime.toIso8601String(),
      });

      _setError('Working offline. Appointment schedule queued.');
      _setLoading(false);
      return true;
    }
  }

  void _updateLocalStatus(String measurementId, MeasurementStatus status, {
    DateTime? appointmentDate,
    DateTime? appointmentTime,
    Map<String, double>? measurements,
    String? notes,
  }) {
    final index = _tailorMeasurementRequests.indexWhere((m) => m.id == measurementId);
    if (index != -1) {
      _tailorMeasurementRequests[index] = _tailorMeasurementRequests[index].copyWith(
        status: status,
        appointmentDate: appointmentDate ?? _tailorMeasurementRequests[index].appointmentDate,
        appointmentTime: appointmentTime ?? _tailorMeasurementRequests[index].appointmentTime,
        measurements: measurements ?? _tailorMeasurementRequests[index].measurements,
        notes: notes ?? _tailorMeasurementRequests[index].notes,
        updatedAt: DateTime.now(),
      );
    }

    final customerIndex = _customerMeasurements.indexWhere((m) => m.id == measurementId);
    if (customerIndex != -1) {
      _customerMeasurements[customerIndex] = _customerMeasurements[customerIndex].copyWith(
        status: status,
        appointmentDate: appointmentDate ?? _customerMeasurements[customerIndex].appointmentDate,
        appointmentTime: appointmentTime ?? _customerMeasurements[customerIndex].appointmentTime,
        measurements: measurements ?? _customerMeasurements[customerIndex].measurements,
        notes: notes ?? _customerMeasurements[customerIndex].notes,
        updatedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<bool> takeMeasurements({
    required String measurementId,
    required Map<String, double> measurements,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _measurementService.takeMeasurements(
        measurementId: measurementId,
        measurements: measurements,
        notes: notes,
      );

      _updateLocalStatus(measurementId, MeasurementStatus.completed, 
          measurements: measurements, notes: notes);
      await _saveAllCaches();

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('MeasurementProvider: takeMeasurements failed, queueing offline. Error: $e');

      // Optimistic update
      _updateLocalStatus(measurementId, MeasurementStatus.completed, 
          measurements: measurements, notes: notes);
      await _saveAllCaches();

      // Queue action
      await SyncService().queueAction('take_measurements', {
        'measurementId': measurementId,
        'measurements': measurements,
        'notes': notes,
      });

      _setError('Working offline. Measurement data queued.');
      _setLoading(false);
      return true;
    }
  }

  Future<bool> cancelMeasurement(String measurementId) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _measurementService.cancelMeasurement(measurementId);

      _updateLocalStatus(measurementId, MeasurementStatus.cancelled);
      await _saveAllCaches();

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('MeasurementProvider: cancelMeasurement failed, queueing offline. Error: $e');

      // Optimistic update
      _updateLocalStatus(measurementId, MeasurementStatus.cancelled);
      await _saveAllCaches();

      // Queue action
      await SyncService().queueAction('cancel_measurement', {
        'measurementId': measurementId,
      });

      _setError('Working offline. Cancellation queued.');
      _setLoading(false);
      return true;
    }
  }

  // Create measurement directly with customer name (for tailor to add customers)
  Future<bool> createMeasurementWithCustomerName({
    required String tailorId,
    required String tailorName,
    required String customerName,
    required Map<String, double> measurements,
    String? notes,
  }) async {
    final customerId = 'customer_${customerName.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
    final tempMeasurement = MeasurementModel(
      id: 'meas_${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      tailorId: tailorId,
      customerName: customerName,
      tailorName: tailorName,
      measurements: measurements,
      notes: notes,
      status: MeasurementStatus.completed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      final measurement = await _measurementService.createMeasurement(
        customerId: customerId,
        tailorId: tailorId,
        customerName: customerName,
        tailorName: tailorName,
        measurements: measurements,
        notes: notes,
        status: MeasurementStatus.completed,
      );

      _tailorMeasurementRequests.insert(0, measurement);
      await _saveAllCaches();
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('MeasurementProvider: createMeasurementWithCustomerName failed, queueing offline. Error: $e');

      // Optimistic update
      _tailorMeasurementRequests.insert(0, tempMeasurement);
      notifyListeners();
      await _saveAllCaches();

      // Queue action
      await SyncService().queueAction('create_measurement', {
        'customerId': customerId,
        'tailorId': tailorId,
        'customerName': customerName,
        'tailorName': tailorName,
        'measurements': measurements,
        'notes': notes,
        'status': MeasurementStatus.completed.name,
      });

      _setError('Working offline. Measurement creation queued.');
      _setLoading(false);
      return true;
    }
  }

  // Fetch all measurements for tailor
  Future<void> fetchAllTailorMeasurements(String tailorId) async {
    try {
      _setLoading(true);
      _setError(null);

      final measurements = await _measurementService.getAllMeasurementsForTailor(tailorId);
      _tailorMeasurementRequests = measurements;
      
      // Cache results
      await LocalStorageService().saveData(
          'all_tailor_measurements', _tailorMeasurementRequests.map((e) => e.toMap()).toList(), userId: tailorId);
    } catch (e) {
      debugPrint('MeasurementProvider: fetchAllTailorMeasurements failed, checking cache. Error: $e');
      final cachedData = LocalStorageService().getData('all_tailor_measurements', userId: tailorId);
      if (cachedData != null && cachedData is List) {
        _tailorMeasurementRequests = cachedData.map((e) => MeasurementModel.fromMap(e)).toList();
        _setError('Working offline. Showing cached measurements.');
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  // Update measurement
  Future<bool> updateMeasurementData({
    required String measurementId,
    Map<String, double>? measurements,
    String? notes,
    String? customerName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _measurementService.updateMeasurement(
        measurementId: measurementId,
        measurements: measurements,
        notes: notes,
      );

      _updateLocalStatus(measurementId, MeasurementStatus.completed, 
          measurements: measurements, notes: notes);
      await _saveAllCaches();

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('MeasurementProvider: updateMeasurementData failed, queueing offline. Error: $e');

      // Optimistic update
      _updateLocalStatus(measurementId, MeasurementStatus.completed, 
          measurements: measurements, notes: notes);
      await _saveAllCaches();

      // Queue action
      await SyncService().queueAction('update_measurement', {
        'measurementId': measurementId,
        'measurements': measurements,
        'notes': notes,
      });

      _setError('Working offline. Measurement update queued.');
      _setLoading(false);
      return true;
    }
  }

  // Delete measurement
  Future<bool> deleteMeasurementData(String measurementId) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _measurementService.deleteMeasurement(measurementId);

      _tailorMeasurementRequests.removeWhere((m) => m.id == measurementId);
      await _saveAllCaches();

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('MeasurementProvider: deleteMeasurementData failed, queueing offline. Error: $e');

      // Optimistic delete
      _tailorMeasurementRequests.removeWhere((m) => m.id == measurementId);
      notifyListeners();
      await _saveAllCaches();

      // Queue action
      await SyncService().queueAction('delete_measurement', {
        'measurementId': measurementId,
      });

      _setError('Working offline. Measurement deletion queued.');
      _setLoading(false);
      return true;
    }
  }

  void clearError() {
    _setError(null);
  }
}


