import 'package:flutter/material.dart';
import 'dart:async';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../utils/network_utils.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  bool _isLoading = false;
  String? _error;
  List<ReviewModel> _reviews = [];
  double _avgRating = 0.0;
  int _ratingCount = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ReviewModel> get reviews => _reviews;
  double get avgRating => _avgRating;
  int get ratingCount => _ratingCount;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> _saveAllCaches(String tailorId) async {
    try {
      await LocalStorageService().saveData('reviews_$tailorId', _reviews.map((e) => e.toMap()).toList());
      await LocalStorageService().saveData('reviews_agg_$tailorId', {
        'avg': _avgRating,
        'count': _ratingCount,
      });
    } catch (e) {
      debugPrint('ReviewProvider: Cache save failed: $e');
    }
  }

  Future<void> loadReviews(String tailorId) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      _reviews = await _reviewService.getReviewsForTailor(tailorId);
      final agg = await _reviewService.getAggregates(tailorId);
      _avgRating = (agg['avg'] ?? 0.0).toDouble();
      _ratingCount = (agg['count'] ?? 0).toInt();

      await _saveAllCaches(tailorId);
      _setLoading(false);
    } catch (e) {
      debugPrint('ReviewProvider: loadReviews failed, checking cache. Error: $e');
      final cachedReviews = LocalStorageService().getData('reviews_$tailorId');
      final cachedAgg = LocalStorageService().getData('reviews_agg_$tailorId');

      if (cachedReviews != null && cachedReviews is List) {
        _reviews = cachedReviews.map((e) => ReviewModel.fromMap(e)).toList();
        if (cachedAgg != null && cachedAgg is Map) {
          _avgRating = (cachedAgg['avg'] ?? 0.0).toDouble();
          _ratingCount = (cachedAgg['count'] ?? 0).toInt();
        }
        _setError('Working offline. Showing cached reviews.');
      } else {
        _setError(e.toString());
      }
      _setLoading(false);
    }
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _reviewService.addReview(review);
      await loadReviews(review.tailorId);
      _setLoading(false);
    } catch (e) {
      debugPrint('ReviewProvider: addReview failed, queueing offline. Error: $e');

      // Optimistic update
      _reviews.insert(0, review);
      
      // Recompute average rating optimistically
      final totalRating = _avgRating * _ratingCount + review.rating;
      _ratingCount += 1;
      _avgRating = totalRating / _ratingCount;
      notifyListeners();

      await _saveAllCaches(review.tailorId);

      // Queue action
      await SyncService().queueAction('add_review', review.toMap());

      _setError('Working offline. Review submission queued.');
      _setLoading(false);
    }
  }
}
