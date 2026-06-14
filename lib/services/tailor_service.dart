import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:math';
import '../models/tailor_model.dart';

class TailorService {
  final _supabase = Supabase.instance.client;

  Future<List<TailorModel>> getAllTailors() async {
    try {
      final List<dynamic> data = await _supabase
          .from('tailors')
          .select();

      return data.map((e) => TailorModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tailors: $e');
    }
  }

  Future<List<TailorModel>> searchTailors({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? serviceType,
    double? minRating,
    String? searchQuery,
  }) async {
    try {
      var query = _supabase.from('tailors').select();

      if (serviceType != null) {
        query = query.contains('services', [serviceType]);
      }

      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      final List<dynamic> data = await query;
      List<TailorModel> tailors = data.map((e) => TailorModel.fromMap(e)).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        tailors = tailors.where((tailor) {
          final businessName = (tailor.businessName ?? '').toLowerCase();
          final name = tailor.name.toLowerCase();
          return businessName.contains(lowerQuery) || name.contains(lowerQuery);
        }).toList();
      }

      final List<TailorModel> nearbyTailors = tailors.where((tailor) {
        // Bypass radius filter if explicitly searching by name
        if (searchQuery != null && searchQuery.isNotEmpty) {
          return true;
        }
        
        // If they are not available, hide them from generic nearby search
        if (!tailor.isAvailable) {
          return false;
        }

        // If tailor has no location set yet, optionally skip distance check or include them
        if (tailor.latitude == 0.0 && tailor.longitude == 0.0) {
           return true; // Still show them if their location failed to save properly
        }

        final distance = _calculateDistance(
          latitude,
          longitude,
          tailor.latitude,
          tailor.longitude,
        );
        return distance <= radiusKm;
      }).toList();

      nearbyTailors.sort((a, b) {
        final distanceA = _calculateDistance(latitude, longitude, a.latitude, a.longitude);
        final distanceB = _calculateDistance(latitude, longitude, b.latitude, b.longitude);
        return distanceA.compareTo(distanceB);
      });

      return nearbyTailors;
    } catch (e) {
      throw Exception('Failed to search tailors: $e');
    }
  }

  Future<TailorModel?> getTailorById(String tailorId) async {
    try {
      final data = await _supabase.from('tailors').select().eq('id', tailorId).single();
      return TailorModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get tailor: $e');
    }
  }

  Future<void> updateTailorAvailability(String tailorId, bool isAvailable) async {
    try {
      await _supabase.from('tailors').update({
        'is_available': isAvailable,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw Exception('Failed to update tailor availability: $e');
    }
  }

  Future<void> updateTailorPricing(String tailorId, Map<String, double> pricing) async {
    try {
      await _supabase.from('tailors').update({
        'pricing': pricing,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw Exception('Failed to update tailor pricing: $e');
    }
  }

  Future<void> addWorkSample(String tailorId, String imageUrl) async {
    try {
      final data = await _supabase.from('tailors').select('work_samples').eq('id', tailorId).single();
      final List<String> currentSamples = List<String>.from(data['work_samples'] ?? []);
      currentSamples.add(imageUrl);

      await _supabase.from('tailors').update({
        'work_samples': currentSamples,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw Exception('Failed to add work sample: $e');
    }
  }

  Future<void> updateTailorLocation(String tailorId, double latitude, double longitude) async {
    try {
      await _supabase.from('tailors').update({
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw Exception('Failed to update tailor location: $e');
    }
  }

  Future<void> updateTailorServices(String tailorId, List<String> services) async {
    try {
      await _supabase.from('tailors').update({
        'services': services,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw Exception('Failed to update tailor services: $e');
    }
  }

  Future<String?> uploadWorkSample(File imageFile, String tailorId) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = 'work_samples/$tailorId/$fileName';
      
      await _supabase.storage.from('images').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );
          
      return _supabase.storage.from('images').getPublicUrl(path);
    } catch (e) {
      throw Exception('Upload work sample failed: $e');
    }
  }

  Future<void> updateTailorSchedule(
    String tailorId, {
    required List<String> availableDays,
    required String startTime,
    required String endTime,
  }) async {
    try {
      await _supabase.from('tailors').update({
        'available_days': availableDays,
        'start_time': startTime,
        'end_time': endTime,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw Exception('Failed to update tailor schedule: $e');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; 
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = (dLat / 2) * (dLat / 2) +
        (dLon / 2) * (dLon / 2) * cos(lat1 * pi / 180) * cos(lat2 * pi / 180);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}

