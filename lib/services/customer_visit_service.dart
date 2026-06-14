import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/customer_visit_model.dart';

class CustomerVisitService {
  final _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // Create a customer visit record
  Future<CustomerVisitModel> createCustomerVisit({
    required String customerId,
    required String tailorId,
    required String customerName,
    required String tailorName,
    required String customerPhone,
    String? customerEmail,
    String? customerAddress,
    String? notes,
  }) async {
    try {
      final visitId = _uuid.v4();
      final now = DateTime.now();

      final visit = CustomerVisitModel(
        id: visitId,
        customerId: customerId,
        tailorId: tailorId,
        customerName: customerName,
        tailorName: tailorName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        customerAddress: customerAddress,
        notes: notes,
        visitDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await _supabase.from('customer_visits').insert(visit.toMap());

      return visit;
    } catch (e) {
      throw Exception('Failed to create customer visit: $e');
    }
  }

  // Get all customer visits for a tailor
  Future<List<CustomerVisitModel>> getTailorCustomerVisits(String tailorId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('customer_visits')
          .select()
          .eq('tailor_id', tailorId)
          .order('visit_date', ascending: false);

      return data.map((e) => CustomerVisitModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to get customer visits: $e');
    }
  }

  // Get all visits for a customer
  Future<List<CustomerVisitModel>> getCustomerVisits(String customerId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('customer_visits')
          .select()
          .eq('customer_id', customerId)
          .order('visit_date', ascending: false);

      return data.map((e) => CustomerVisitModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to get customer visits: $e');
    }
  }

  // Get customer visit by ID
  Future<CustomerVisitModel?> getCustomerVisitById(String visitId) async {
    try {
      final data = await _supabase
          .from('customer_visits')
          .select()
          .eq('id', visitId)
          .single();

      return CustomerVisitModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get customer visit: $e');
    }
  }
}
