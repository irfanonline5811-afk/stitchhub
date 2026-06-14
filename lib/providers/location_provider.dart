import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  String? _error;
  bool _locationPermissionGranted = false;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get locationPermissionGranted => _locationPermissionGranted;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      _locationPermissionGranted = status == PermissionStatus.granted;
      notifyListeners();
      return _locationPermissionGranted;
    } catch (e) {
      _setError('Error requesting location permission: $e');
      return false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      _setLoading(true);
      _setError(null);

      // First, request location permission using permission_handler
      final permissionStatus = await Permission.location.request();
      if (permissionStatus != PermissionStatus.granted) {
        if (permissionStatus == PermissionStatus.permanentlyDenied) {
          _setError('Location permissions are permanently denied. Please enable them from app settings.');
        } else {
          _setError('Location permissions are required. Please grant location permission.');
        }
        _locationPermissionGranted = false;
        _setLoading(false);
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to open location settings
        bool opened = await Geolocator.openLocationSettings();
        if (!opened) {
          _setError('Location services are disabled. Please enable them from device settings.');
        } else {
          _setError('Please enable location services and try again.');
        }
        _setLoading(false);
        return;
      }

      // Check location permission with Geolocator as well
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setError('Location permissions are denied');
          _setLoading(false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setError('Location permissions are permanently denied. Please enable them from app settings.');
        _setLoading(false);
        return;
      }

      // Try to get last known position first (faster)
      Position? lastKnownPosition;
      try {
        lastKnownPosition = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition != null) {
          // Check if last known position is recent (within 5 minutes)
          final now = DateTime.now();
          final positionTime = lastKnownPosition.timestamp;
          final difference = now.difference(positionTime);
          if (difference.inMinutes < 5) {
            _currentPosition = lastKnownPosition;
            await _getAddressFromPosition(_currentPosition!);
            _locationPermissionGranted = true;
            _setLoading(false);
            return;
          }
        }
      } catch (e) {
        // Ignore error, will try to get fresh position
        debugPrint('Could not get last known position: $e');
      }

      // Try with medium accuracy first (faster)
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        // If medium accuracy fails, try with low accuracy (fastest)
        debugPrint('Medium accuracy failed, trying low accuracy: $e');
        try {
          _currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 20),
          );
        } catch (e2) {
          // If both fail, use last known position if available
          if (lastKnownPosition != null) {
            debugPrint('Using last known position as fallback');
            _currentPosition = lastKnownPosition;
          } else {
            // Re-throw the error if no fallback available
            rethrow;
          }
        }
      }

      // Get address from coordinates
      if (_currentPosition != null) {
        await _getAddressFromPosition(_currentPosition!);
        _locationPermissionGranted = true;
        _setLoading(false);
      } else {
        throw Exception('Could not get location');
      }
    } catch (e) {
      String errorMessage = 'Error getting current location';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Location request timed out. Please check your GPS signal and try again.';
      } else if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = 'Location permission denied. Please grant location permission.';
      } else {
        errorMessage = 'Error getting location: ${e.toString()}';
      }
      _setError(errorMessage);
      _setLoading(false);
    }
  }

  Future<void> _getAddressFromPosition(Position position) async {
    try {
      // This would typically use a geocoding service
      // For now, we'll set a placeholder address
      _currentAddress = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      notifyListeners();
    } catch (e) {
      _setError('Error getting address: $e');
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Return distance in kilometers
  }

  void clearError() {
    _setError(null);
  }
}



