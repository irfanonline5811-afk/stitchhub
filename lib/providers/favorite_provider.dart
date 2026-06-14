import 'package:flutter/material.dart';
import 'dart:async';
import '../models/tailor_model.dart';
import '../services/favorite_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../utils/network_utils.dart';

class FavoriteProvider with ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  
  List<TailorModel> _favoriteTailors = [];
  Set<String> _favoriteTailorIds = {};
  bool _isLoading = false;
  String? _error;

  List<TailorModel> get favoriteTailors => _favoriteTailors;
  Set<String> get favoriteTailorIds => _favoriteTailorIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isFavorite(String tailorId) {
    return _favoriteTailorIds.contains(tailorId);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load all favorites for a customer
  Future<void> loadFavorites(String customerId) async {
    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      final favorites = await _favoriteService.getFavoriteTailors(customerId);
      _favoriteTailors = favorites;
      _favoriteTailorIds = favorites.map((t) => t.id).toSet();

      // Cache
      await LocalStorageService().saveData('favorites', favorites.map((e) => e.toMap()).toList(), userId: customerId);

      _setLoading(false);
    } catch (e) {
      debugPrint('FavoriteProvider: loadFavorites failed, checking cache. Error: $e');
      final cached = LocalStorageService().getData('favorites', userId: customerId);
      if (cached != null && cached is List) {
        _favoriteTailors = cached.map((e) => TailorModel.fromMap(e)).toList();
        _favoriteTailorIds = _favoriteTailors.map((t) => t.id).toSet();
        _setError('Working offline. Showing cached favorites.');
      } else {
        _setError(e.toString());
      }
      _setLoading(false);
    }
  }

  // Add to favorites
  Future<void> addToFavorites(String customerId, String tailorId) async {
    try {
      _setError(null);
      
      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _favoriteService.addToFavorites(customerId, tailorId);
      
      // Update local state
      _favoriteTailorIds.add(tailorId);
      await loadFavorites(customerId);
      notifyListeners();
    } catch (e) {
      debugPrint('FavoriteProvider: addToFavorites failed, queueing offline. Error: $e');

      // Optimistic update
      _favoriteTailorIds.add(tailorId);
      notifyListeners();

      // Save cache
      await LocalStorageService().saveData('favorites', _favoriteTailors.map((e) => e.toMap()).toList(), userId: customerId);

      // Queue action
      await SyncService().queueAction('add_to_favorites', {
        'customerId': customerId,
        'tailorId': tailorId,
      });

      _setError('Working offline. Favorite added.');
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String customerId, String tailorId) async {
    try {
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _favoriteService.removeFromFavorites(customerId, tailorId);
      
      // Update local state
      _favoriteTailorIds.remove(tailorId);
      _favoriteTailors.removeWhere((t) => t.id == tailorId);
      
      // Save cache
      await LocalStorageService().saveData('favorites', _favoriteTailors.map((e) => e.toMap()).toList(), userId: customerId);
      notifyListeners();
    } catch (e) {
      debugPrint('FavoriteProvider: removeFromFavorites failed, queueing offline. Error: $e');

      // Optimistic update
      _favoriteTailorIds.remove(tailorId);
      _favoriteTailors.removeWhere((t) => t.id == tailorId);
      notifyListeners();

      // Save cache
      await LocalStorageService().saveData('favorites', _favoriteTailors.map((e) => e.toMap()).toList(), userId: customerId);

      // Queue action
      await SyncService().queueAction('remove_from_favorites', {
        'customerId': customerId,
        'tailorId': tailorId,
      });

      _setError('Working offline. Favorite removed.');
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String customerId, String tailorId) async {
    if (isFavorite(tailorId)) {
      await removeFromFavorites(customerId, tailorId);
    } else {
      await addToFavorites(customerId, tailorId);
    }
  }

  // Refresh favorites
  Future<void> refreshFavorites(String customerId) async {
    await loadFavorites(customerId);
  }
}

