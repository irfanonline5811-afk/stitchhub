import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/tailor_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'user_type': userType},
      );

      final User? user = res.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.id,
          email: email,
          name: name,
          phone: phone,
          userType: userType,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Try to update the user_type right away in case a trigger defaulted it
        try {
          await _supabase.from('users').update({
            'user_type': userType,
            'name': name,
            'phone': phone,
          }).eq('id', user.id);
          
          if (userType == 'tailor') {
            final tailorModel = TailorModel(
              id: user.id,
              email: email,
              name: name,
              phone: phone,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              latitude: 0.0,
              longitude: 0.0,
              isAvailable: true,
            );
            await _supabase.from('tailors').upsert(tailorModel.toMap());
          }
        } catch (dbError) {
          // If upsert fails (e.g. RLS issues), we still have the auth user.
          // In development, RLS might be the issue if email is not confirmed.
          debugPrint('AuthService: Database profile update error: $dbError');
          // Re-throw the exception to ensure it's not silently swallowed
          throw Exception('Database profile update failed: $dbError');
        }
        return userModel;
      }
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
    return null;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        return await getCurrentUser();
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
    return null;
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      return UserModel.fromMap(data);
    }
    return null;
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromMap(data);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<TailorModel?> getTailorProfile(String userId) async {
    try {
      final data = await _supabase
          .from('tailors')
          .select()
          .eq('id', userId)
          .single();
      return TailorModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed fetching tailor profile: $e');
    }
  }

  Future<UserModel?> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    final Map<String, dynamic> updateData = {
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;
    if (profileImageUrl != null) {
      updateData['profile_image_url'] = profileImageUrl;
    }

    await _supabase.from('users').update(updateData).eq('id', userId);
    return await getCurrentUser();
  }

  Future<TailorModel?> updateTailorProfile({
    required String userId,
    Map<String, dynamic>? updateData,
  }) async {
    try {
      if (updateData != null) {
        updateData['updated_at'] = DateTime.now().toIso8601String();
        await _supabase.from('tailors').upsert(updateData);
      }
      return await getTailorProfile(userId);
    } catch (e) {
      throw Exception('Update tailor profile failed: $e');
    }
  }

  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final String path = 'profiles/$userId.jpg';
      await _supabase.storage.from('images').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );
      final String publicUrl =
          _supabase.storage.from('images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Upload profile image failed: $e');
    }
  }

  Future<void> deleteAccount(String userId) async {
    try {
      await _supabase.from('users').delete().eq('id', userId);
      await signOut();
    } catch (e) {
      throw Exception('Delete account failed: $e');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
