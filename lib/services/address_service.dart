import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/address_model.dart';

class AddressService {
  final _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final id = _uuid.v4();
      final withId = AddressModel(
        id: id,
        userId: address.userId,
        label: address.label,
        addressLine1: address.addressLine1,
        addressLine2: address.addressLine2,
        city: address.city,
        state: address.state,
        country: address.country,
        postalCode: address.postalCode,
        latitude: address.latitude,
        longitude: address.longitude,
        isDefault: address.isDefault,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (withId.isDefault) {
        await _unsetDefault(address.userId);
      }

      await _supabase.from('addresses').insert(withId.toMap());
      return withId;
    } catch (e) {
      debugPrint('Error adding address: $e');
      rethrow;
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    try {
      if (address.isDefault) {
        await _unsetDefault(address.userId);
      }
      await _supabase.from('addresses').update({
        ...address.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', address.id);
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _supabase.from('addresses').delete().eq('id', addressId);
    } catch (e) {
      debugPrint('Error deleting address: $e');
      rethrow;
    }
  }

  Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return data.map((e) => AddressModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
      return [];
    }
  }

  Future<AddressModel?> getDefaultAddress(String userId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .eq('is_default', true)
          .limit(1);

      if (data.isNotEmpty) {
        return AddressModel.fromMap(data.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting default address: $e');
      return null;
    }
  }

  Future<void> setDefault(String userId, String addressId) async {
    try {
      await _unsetDefault(userId);
      await _supabase.from('addresses').update({
        'is_default': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', addressId);
    } catch (e) {
      debugPrint('Error setting default: $e');
      rethrow;
    }
  }

  Future<void> _unsetDefault(String userId) async {
    try {
      await _supabase.from('addresses').update({
        'is_default': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId).eq('is_default', true);
    } catch (e) {
      debugPrint('Error unsetting default: $e');
    }
  }
}
