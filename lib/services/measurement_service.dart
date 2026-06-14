import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/measurement_model.dart';

class MeasurementService {
  final _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<MeasurementModel?> createMeasurementRequest({
    required String customerId,
    required String tailorId,
    required String customerName,
    required String tailorName,
    String? notes,
  }) async {
    try {
      final String measurementId = _uuid.v4();
      final now = DateTime.now();
      
      final measurement = MeasurementModel(
        id: measurementId,
        customerId: customerId,
        tailorId: tailorId,
        customerName: customerName,
        tailorName: tailorName,
        status: MeasurementStatus.pending,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      await _supabase.from('measurements').insert(measurement.toMap());
      return measurement;
    } catch (e) {
      throw Exception('Failed to create measurement request: $e');
    }
  }

  Future<List<MeasurementModel>> getCustomerMeasurements(String customerId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('measurements')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return data.map((e) => MeasurementModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch customer measurements: $e');
    }
  }

  Future<List<MeasurementModel>> getTailorMeasurementRequests(String tailorId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('measurements')
          .select()
          .eq('tailor_id', tailorId)
          .order('created_at', ascending: false);

      return data.map((e) => MeasurementModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tailor measurement requests: $e');
    }
  }

  Future<MeasurementModel?> getMeasurementById(String measurementId) async {
    try {
      final data = await _supabase
          .from('measurements')
          .select()
          .eq('id', measurementId)
          .single();

      return MeasurementModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get measurement: $e');
    }
  }

  Future<void> scheduleAppointment({
    required String measurementId,
    required DateTime appointmentDate,
    required DateTime appointmentTime,
  }) async {
    try {
      await _supabase.from('measurements').update({
        'status': MeasurementStatus.scheduled.toString().split('.').last,
        'appointment_date': appointmentDate.toIso8601String(),
        'appointment_time': appointmentTime.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', measurementId);
    } catch (e) {
      throw Exception('Failed to schedule appointment: $e');
    }
  }

  Future<void> takeMeasurements({
    required String measurementId,
    required Map<String, double> measurements,
    String? notes,
  }) async {
    try {
      await _supabase.from('measurements').update({
        'status': MeasurementStatus.completed.toString().split('.').last,
        'measurements': measurements,
        'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', measurementId);
    } catch (e) {
      throw Exception('Failed to save measurements: $e');
    }
  }

  Future<void> updateMeasurementStatus({
    required String measurementId,
    required MeasurementStatus status,
  }) async {
    try {
      await _supabase.from('measurements').update({
        'status': status.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', measurementId);
    } catch (e) {
      throw Exception('Failed to update measurement status: $e');
    }
  }

  Future<void> cancelMeasurement(String measurementId) async {
    try {
      await _supabase.from('measurements').update({
        'status': MeasurementStatus.cancelled.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', measurementId);
    } catch (e) {
      throw Exception('Failed to cancel measurement: $e');
    }
  }

  // Tailor requests measurement from customer
  Future<MeasurementModel?> requestMeasurementFromCustomer({
    required String tailorId,
    required String customerId,
    required String tailorName,
    required String customerName,
    String? notes,
  }) async {
    try {
      final String measurementId = _uuid.v4();
      final now = DateTime.now();
      
      final measurement = MeasurementModel(
        id: measurementId,
        customerId: customerId,
        tailorId: tailorId,
        customerName: customerName,
        tailorName: tailorName,
        status: MeasurementStatus.pending,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      await _supabase.from('measurements').insert(measurement.toMap());
      return measurement;
    } catch (e) {
      throw Exception('Failed to request measurement: $e');
    }
  }

  // Create a new measurement (Tailor can directly add customer measurements)
  Future<MeasurementModel> createMeasurement({
    required String customerId,
    required String tailorId,
    required String customerName,
    required String tailorName,
    Map<String, double>? measurements,
    String? notes,
    MeasurementStatus status = MeasurementStatus.completed,
  }) async {
    try {
      final String measurementId = _uuid.v4();
      final now = DateTime.now();
      
      final measurement = MeasurementModel(
        id: measurementId,
        customerId: customerId,
        tailorId: tailorId,
        customerName: customerName,
        tailorName: tailorName,
        status: status,
        notes: notes,
        measurements: measurements ?? {},
        createdAt: now,
        updatedAt: now,
      );

      await _supabase.from('measurements').insert(measurement.toMap());
      return measurement;
    } catch (e) {
      throw Exception('Failed to create measurement: $e');
    }
  }

  // Update an existing measurement
  Future<void> updateMeasurement({
    required String measurementId,
    Map<String, double>? measurements,
    String? notes,
    MeasurementStatus? status,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (measurements != null) {
        updateData['measurements'] = measurements;
      }
      if (notes != null) {
        updateData['notes'] = notes;
      }
      if (status != null) {
        updateData['status'] = status.toString().split('.').last;
      }

      await _supabase.from('measurements').update(updateData).eq('id', measurementId);
    } catch (e) {
      throw Exception('Failed to update measurement: $e');
    }
  }

  // Delete a measurement
  Future<void> deleteMeasurement(String measurementId) async {
    try {
      await _supabase.from('measurements').delete().eq('id', measurementId);
    } catch (e) {
      throw Exception('Failed to delete measurement: $e');
    }
  }

  // Get all measurements for a tailor (all customers)
  Future<List<MeasurementModel>> getAllMeasurementsForTailor(String tailorId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('measurements')
          .select()
          .eq('tailor_id', tailorId)
          .order('updated_at', ascending: false);

      return data.map((e) => MeasurementModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tailor measurements: $e');
    }
  }
}


