import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/review_model.dart';

class ReviewService {
  final _supabase = Supabase.instance.client;

  Future<void> addReview(ReviewModel review) async {
    try {
      await _supabase.from('reviews').insert(review.toMap());
      await _updateTailorAggregates(review.tailorId);
    } catch (e) {
      debugPrint('Error adding review: $e');
      rethrow;
    }
  }

  Future<List<ReviewModel>> getReviewsForTailor(String tailorId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('reviews')
          .select()
          .eq('tailor_id', tailorId)
          .order('created_at', ascending: false);

      return data.map((e) => ReviewModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  Stream<List<ReviewModel>> streamReviewsForTailor(String tailorId) {
    return _supabase
        .from('reviews')
        .stream(primaryKey: ['id'])
        .eq('tailor_id', tailorId)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => ReviewModel.fromMap(e)).toList());
  }

  Future<Map<String, dynamic>> getAggregates(String tailorId) async {
    try {
      final List<dynamic> reviews = await _supabase
          .from('reviews')
          .select('rating')
          .eq('tailor_id', tailorId);

      if (reviews.isEmpty) return {'avg': 0.0, 'count': 0};

      double sum = reviews.fold(0, (sum, item) => sum + (item['rating'] as num).toDouble());
      final count = reviews.length;
      return {'avg': sum / count, 'count': count};
    } catch (e) {
      debugPrint('Error computing aggregates: $e');
      return {'avg': 0.0, 'count': 0};
    }
  }

  Future<void> _updateTailorAggregates(String tailorId) async {
    final agg = await getAggregates(tailorId);
    try {
      await _supabase.from('tailors').update({
        'rating': agg['avg'],
        'total_reviews': agg['count'],
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      debugPrint('Error updating tailor aggregates: $e');
    }
  }
}













