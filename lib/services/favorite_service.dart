import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/tailor_model.dart';

class FavoriteService {
  final _supabase = Supabase.instance.client;

  // Add tailor to favorites
  Future<void> addToFavorites(String customerId, String tailorId) async {
    try {
      await _supabase.from('favorites').upsert({
        'id': '${customerId}_$tailorId',
        'customer_id': customerId,
        'tailor_id': tailorId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  // Remove tailor from favorites
  Future<void> removeFromFavorites(String customerId, String tailorId) async {
    try {
      await _supabase.from('favorites').delete().eq('id', '${customerId}_$tailorId');
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  // Check if tailor is favorited
  Future<bool> isFavorite(String customerId, String tailorId) async {
    try {
      final data = await _supabase
          .from('favorites')
          .select()
          .eq('id', '${customerId}_$tailorId')
          .maybeSingle();
      return data != null;
    } catch (e) {
      debugPrint('Error checking favorite: $e');
      return false;
    }
  }

  // Get all favorite tailor IDs for a customer
  Future<List<String>> getFavoriteTailorIds(String customerId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('favorites')
          .select('tailor_id')
          .eq('customer_id', customerId);

      return data.map((e) => e['tailor_id'] as String).toList();
    } catch (e) {
      throw Exception('Failed to get favorite tailor IDs: $e');
    }
  }

  // Get all favorite tailors with full details
  Future<List<TailorModel>> getFavoriteTailors(String customerId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('favorites')
          .select('tailors(*)')
          .eq('customer_id', customerId);

      return data
          .where((e) => e['tailors'] != null)
          .map((e) => TailorModel.fromMap(e['tailors']))
          .toList();
    } catch (e) {
      throw Exception('Failed to get favorite tailors: $e');
    }
  }
}
