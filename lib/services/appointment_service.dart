import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import 'notification_service.dart';

class AppointmentService {
  final _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<AppointmentModel> createAppointment(
      AppointmentModel appointment) async {
    try {
      final id = _uuid.v4();
      final withId = AppointmentModel(
        id: id,
        customerId: appointment.customerId,
        customerName: appointment.customerName,
        tailorId: appointment.tailorId,
        tailorName: appointment.tailorName,
        startTime: appointment.startTime,
        endTime: appointment.endTime,
        notes: appointment.notes,
        status: AppointmentStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _supabase.from('appointments').insert(withId.toMap());

      // Notify Tailor
      await NotificationService().sendNotification(
        userId: withId.tailorId,
        title: 'New Appointment Request',
        body: '${withId.customerName} has requested an appointment on ${_formatDate(withId.startTime)}',
        data: {
          'type': 'new_appointment',
          'appointmentId': id,
        },
      );

      return withId;
    } catch (e) {
      debugPrint('Create appointment error: $e');
      rethrow;
    }
  }

  Future<void> approveAppointment(String appointmentId) async {
    await _supabase.from('appointments').update({
      'status': 'approved',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', appointmentId);

    // Notify Customer
    final data = await _supabase.from('appointments').select().eq('id', appointmentId).single();
    final appointment = AppointmentModel.fromMap(data);
    await NotificationService().sendNotification(
      userId: appointment.customerId,
      title: 'Appointment Approved',
      body: 'Your appointment with ${appointment.tailorName} has been approved.',
      data: {
        'type': 'appointment_update',
        'appointmentId': appointmentId,
      },
    );
  }

  Future<void> declineAppointment(String appointmentId) async {
    await _supabase.from('appointments').update({
      'status': 'declined',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', appointmentId);

    // Notify Customer
    final data = await _supabase.from('appointments').select().eq('id', appointmentId).single();
    final appointment = AppointmentModel.fromMap(data);
    await NotificationService().sendNotification(
      userId: appointment.customerId,
      title: 'Appointment Declined',
      body: 'Your appointment with ${appointment.tailorName} has been declined.',
      data: {
        'type': 'appointment_update',
        'appointmentId': appointmentId,
      },
    );
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await _supabase.from('appointments').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', appointmentId);
  }

  Stream<List<AppointmentModel>> getCustomerAppointmentsStream(
      String customerId) {
    return _supabase
        .from('appointments')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('start_time', ascending: true)
        .map((data) => data.map((e) => AppointmentModel.fromMap(e)).toList());
  }

  Stream<List<AppointmentModel>> getTailorAppointmentsStream(String tailorId) {
    return _supabase
        .from('appointments')
        .stream(primaryKey: ['id'])
        .eq('tailor_id', tailorId)
        .order('start_time', ascending: true)
        .map((data) => data.map((e) => AppointmentModel.fromMap(e)).toList());
  }

  Future<List<AppointmentModel>> getCustomerAppointments(
      String customerId) async {
    final data = await _supabase
        .from('appointments')
        .select()
        .eq('customer_id', customerId)
        .order('start_time', ascending: true);
    
    return (data as List).map((e) => AppointmentModel.fromMap(e)).toList();
  }

  Future<List<AppointmentModel>> getTailorAppointments(String tailorId) async {
    final data = await _supabase
        .from('appointments')
        .select()
        .eq('tailor_id', tailorId)
        .order('start_time', ascending: true);
    
    return (data as List).map((e) => AppointmentModel.fromMap(e)).toList();
  }
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}


