import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/tailor_model.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';
import '../utils/network_utils.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  TailorModel? _tailor;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  TailorModel? get tailor => _tailor;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isTailor => _user?.userType == 'tailor';

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      debugPrint('AuthProvider: Starting sign up process');

      // Check network connectivity first
      final hasConnection = await NetworkUtils.checkConnectivity();
      if (!hasConnection) {
        _setError('No internet connection. Please check your network and try again.');
        return false;
      }

      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        userType: userType,
      );
      debugPrint('AuthProvider: Sign up result - user: $user');

      if (user != null) {
        _user = user;
        debugPrint('AuthProvider: User set, userType: ${user.userType}');
        if (user.userType == 'tailor') {
          _tailor = TailorModel(
            id: user.id,
            email: user.email,
            name: user.name,
            phone: user.phone,
            profileImageUrl: user.profileImageUrl,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
            latitude: 0.0,
            longitude: 0.0,
          );
        }
        
        // Start live notification listeners
        NotificationService().startRealtimeListeners(user.id);
        
        debugPrint('AuthProvider: Sign up successful');
        return true;
      }
      debugPrint('AuthProvider: Sign up failed - user is null');
      _setError('Failed to create account. Please try again.');
      return false;
    } catch (e) {
      debugPrint('AuthProvider: Sign up error: $e');
      final errorMessage = ErrorHandler.getErrorMessage(e);
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      debugPrint('AuthProvider: Starting sign in process');

      // Check network connectivity first
      final hasConnection = await NetworkUtils.checkConnectivity();
      if (!hasConnection) {
        _setError('No internet connection. Please check your network and try again.');
        return false;
      }

      final user = await _authService.signIn(email: email, password: password);
      debugPrint('AuthProvider: Sign in result - user: $user');

      if (user != null) {
        _user = user;
        debugPrint('AuthProvider: User set, userType: ${user.userType}');
        if (user.userType == 'tailor') {
          await _loadTailorProfile(user.id);
        }
        
        // Start live notification listeners
        NotificationService().startRealtimeListeners(user.id);
        
        debugPrint('AuthProvider: Sign in successful');
        return true;
      }
      debugPrint('AuthProvider: Sign in failed - user is null');
      _setError('Invalid credentials. Please check your email and password.');
      return false;
    } catch (e) {
      debugPrint('AuthProvider: Sign in error: $e');
      final errorMessage = ErrorHandler.getErrorMessage(e);
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadTailorProfile(String userId) async {
    try {
      final tailor = await _authService.getTailorProfile(userId);
      if (tailor != null) {
        _tailor = tailor;
      } else {
        _setError('Tailor profile returned null.');
        _tailor = TailorModel(
          id: userId,
          email: _user?.email ?? '',
          name: _user?.name ?? '',
          phone: _user?.phone ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error loading tailor profile: $e');
      _setError('Profile Load Error: $e');
      _tailor = TailorModel(
        id: userId,
        email: _user?.email ?? '',
        name: _user?.name ?? '',
        phone: _user?.phone ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      
      // Stop live notification listeners
      NotificationService().clearListeners();
      
      _user = null;
      _tailor = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> deleteAccount() async {
    if (_user == null) return false;
    try {
      _setLoading(true);
      _setError(null);
      await _authService.deleteAccount(_user!.id);
      
      // Stop live notification listeners
      NotificationService().clearListeners();
      
      _user = null;
      _tailor = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    if (_user == null) return;

    try {
      _setLoading(true);
      _setError(null);

      final updatedUser = await _authService.updateProfile(
        userId: _user!.id,
        name: name,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );

      if (updatedUser != null) {
        _user = updatedUser;
        notifyListeners();
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> updateTailorProfile(TailorModel tailor) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedTailor = await _authService.updateTailorProfile(
        userId: tailor.id,
        updateData: tailor.toMap(),
      );
      if (updatedTailor != null) {
        _tailor = updatedTailor;
        // Also update user profile image if it was updated
        if (tailor.profileImageUrl != null && _user != null) {
          _user = _user!.copyWith(profileImageUrl: tailor.profileImageUrl);
        }
        notifyListeners();
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkAuthState() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _user = user;
        if (user.userType == 'tailor') {
          await _loadTailorProfile(user.id);
        }
        
        // Start live notification listeners
        NotificationService().startRealtimeListeners(user.id);
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking auth state: $e');
    }
  }
}
