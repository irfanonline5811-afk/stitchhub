import 'package:flutter/material.dart';
import '../models/tailor_model.dart';
import '../services/tailor_service.dart';
import '../models/search_filter_model.dart';
import '../services/local_storage_service.dart';

class TailorProvider with ChangeNotifier {
  final TailorService _tailorService = TailorService();
  List<TailorModel> _tailors = [];
  List<TailorModel> _nearbyTailors = [];
  SearchFilterModel _filters = const SearchFilterModel();
  bool _isLoading = false;
  String? _error;

  List<TailorModel> get tailors => _tailors;
  List<TailorModel> get nearbyTailors => _nearbyTailors;
  SearchFilterModel get filters => _filters;
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

  Future<void> fetchAllTailors() async {
    try {
      _setLoading(true);
      _setError(null);

      final tailors = await _tailorService.getAllTailors();
      _tailors = tailors;
      
      // Cache results
      await LocalStorageService().saveData(
          'all_tailors', _tailors.map((e) => e.toMap()).toList());
          
    } catch (e) {
      debugPrint('TailorProvider: Fetch error, checking cache. Error: $e');
      // Load from cache if offline
      final cachedData = LocalStorageService().getData('all_tailors');
      if (cachedData != null && cachedData is List) {
        _tailors = cachedData.map((e) => TailorModel.fromMap(e)).toList();
        _setError('Working offline. Showing cached results.');
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchTailors({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? serviceType,
    double? minRating,
    String? searchQuery,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final tailors = await _tailorService.searchTailors(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        serviceType: serviceType,
        minRating: minRating,
        searchQuery: searchQuery,
      );
      _nearbyTailors = _applyFilters(tailors, latitude, longitude);
      
      // Cache results
      await LocalStorageService().saveData(
          'nearby_tailors', _nearbyTailors.map((e) => e.toMap()).toList());
      
    } catch (e) {
      debugPrint('TailorProvider: Search error, checking cache. Error: $e');
      // Load from cache if offline
      final cachedData = LocalStorageService().getData('nearby_tailors');
      if (cachedData != null && cachedData is List) {
        _nearbyTailors = cachedData.map((e) => TailorModel.fromMap(e)).toList();
        _setError('Working offline. Showing cached results.');
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  void setFilters(SearchFilterModel filters,
      {double? latitude, double? longitude}) {
    _filters = filters;
    if (latitude != null && longitude != null) {
      _nearbyTailors = _applyFilters(_nearbyTailors, latitude, longitude);
    }
    notifyListeners();
  }

  List<TailorModel> _applyFilters(
      List<TailorModel> source, double lat, double lng) {
    Iterable<TailorModel> list = source;
    // rating
    if (_filters.minRating != null) {
      list = list.where((t) => t.rating >= _filters.minRating!);
    }
    // services
    if (_filters.services.isNotEmpty) {
      list = list.where((t) {
        final tailorServices = t.services.map((s) => s.toLowerCase()).toSet();
        return _filters.services.every((s) => tailorServices.contains(s));
      });
    }
    // price (use min of pricing map)
    if (_filters.maxPrice != null) {
      list = list.where((t) {
        if (t.pricing.isEmpty) return false;
        final minPrice = t.pricing.values.reduce((a, b) => a < b ? a : b);
        return minPrice <= _filters.maxPrice!;
      });
    }
    // distance filter handled server-side typically; keep as-is

    final result = list.toList();
    // sort
    switch (_filters.sortBy) {
      case TailorSortBy.ratingDesc:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case TailorSortBy.priceAsc:
        double minPrice(TailorModel t) => t.pricing.isEmpty
            ? double.infinity
            : t.pricing.values.reduce((a, b) => a < b ? a : b);
        result.sort((a, b) => minPrice(a).compareTo(minPrice(b)));
        break;
      case TailorSortBy.distanceAsc:
        // Compute simple squared distance; treat (0,0) as far/unknown
        double dist(TailorModel t) {
          if ((t.latitude == 0.0 && t.longitude == 0.0)) return double.infinity;
          final dLat = (t.latitude - lat).abs();
          final dLng = (t.longitude - lng).abs();
          return dLat * dLat + dLng * dLng; // rough ordering
        }
        result.sort((a, b) => dist(a).compareTo(dist(b)));
        break;
      case TailorSortBy.relevance:
        break;
    }
    return result;
  }

  Future<void> getTailorById(String tailorId) async {
    try {
      _setLoading(true);
      _setError(null);

      final tailor = await _tailorService.getTailorById(tailorId);
      if (tailor != null) {
        final index = _tailors.indexWhere((t) => t.id == tailorId);
        if (index != -1) {
          _tailors[index] = tailor;
        } else {
          _tailors.add(tailor);
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTailorAvailability(
      String tailorId, bool isAvailable) async {
    try {
      _setLoading(true);
      _setError(null);

      await _tailorService.updateTailorAvailability(tailorId, isAvailable);

      // Update local state
      final index = _tailors.indexWhere((t) => t.id == tailorId);
      if (index != -1) {
        _tailors[index] =
            _tailors[index].copyWithTailor(isAvailable: isAvailable);
      }

      final nearbyIndex = _nearbyTailors.indexWhere((t) => t.id == tailorId);
      if (nearbyIndex != -1) {
        _nearbyTailors[nearbyIndex] = _nearbyTailors[nearbyIndex]
            .copyWithTailor(isAvailable: isAvailable);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTailorPricing(
      String tailorId, Map<String, double> pricing) async {
    try {
      _setLoading(true);
      _setError(null);

      await _tailorService.updateTailorPricing(tailorId, pricing);

      // Update local state
      final index = _tailors.indexWhere((t) => t.id == tailorId);
      if (index != -1) {
        _tailors[index] = _tailors[index].copyWithTailor(pricing: pricing);
      }

      final nearbyIndex = _nearbyTailors.indexWhere((t) => t.id == tailorId);
      if (nearbyIndex != -1) {
        _nearbyTailors[nearbyIndex] =
            _nearbyTailors[nearbyIndex].copyWithTailor(pricing: pricing);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addWorkSample(String tailorId, String imageUrl) async {
    try {
      _setLoading(true);
      _setError(null);

      await _tailorService.addWorkSample(tailorId, imageUrl);

      // Update local state
      final index = _tailors.indexWhere((t) => t.id == tailorId);
      if (index != -1) {
        final currentSamples = List<String>.from(_tailors[index].workSamples);
        currentSamples.add(imageUrl);
        _tailors[index] =
            _tailors[index].copyWithTailor(workSamples: currentSamples);
      }

      final nearbyIndex = _nearbyTailors.indexWhere((t) => t.id == tailorId);
      if (nearbyIndex != -1) {
        final currentSamples =
            List<String>.from(_nearbyTailors[nearbyIndex].workSamples);
        currentSamples.add(imageUrl);
        _nearbyTailors[nearbyIndex] = _nearbyTailors[nearbyIndex]
            .copyWithTailor(workSamples: currentSamples);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
}
