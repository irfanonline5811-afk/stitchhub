import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressProvider with ChangeNotifier {
  final AddressService _addressService = AddressService();

  bool _isLoading = false;
  String? _error;
  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AddressModel> get addresses => _addresses;
  AddressModel? get selectedAddress => _selectedAddress;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String? val) {
    _error = val;
    notifyListeners();
  }

  void setSelected(AddressModel? address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> loadAddresses(String userId) async {
    try {
      _setLoading(true);
      _setError(null);
      _addresses = await _addressService.getUserAddresses(userId);
      if (_addresses.isEmpty) {
        _selectedAddress = null;
      } else {
        final idx = _addresses.indexWhere((a) => a.isDefault);
        _selectedAddress = idx != -1 ? _addresses[idx] : _addresses.first;
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> addAddress(AddressModel address) async {
    try {
      _setLoading(true);
      final added = await _addressService.addAddress(address);
      _addresses.insert(0, added);
      if (added.isDefault) {
        _selectedAddress = added;
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    try {
      _setLoading(true);
      await _addressService.updateAddress(address);
      final idx = _addresses.indexWhere((a) => a.id == address.id);
      if (idx != -1) {
        _addresses[idx] = address;
      }
      if (address.isDefault) {
        _selectedAddress = address;
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      _setLoading(true);
      await _addressService.deleteAddress(addressId);
      _addresses.removeWhere((a) => a.id == addressId);
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> setDefault(String userId, String addressId) async {
    try {
      _setLoading(true);
      await _addressService.setDefault(userId, addressId);
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = AddressModel(
          id: _addresses[i].id,
          userId: _addresses[i].userId,
          label: _addresses[i].label,
          addressLine1: _addresses[i].addressLine1,
          addressLine2: _addresses[i].addressLine2,
          city: _addresses[i].city,
          state: _addresses[i].state,
          country: _addresses[i].country,
          postalCode: _addresses[i].postalCode,
          latitude: _addresses[i].latitude,
          longitude: _addresses[i].longitude,
          isDefault: _addresses[i].id == addressId,
          createdAt: _addresses[i].createdAt,
          updatedAt: DateTime.now(),
        );
      }
      _selectedAddress = _addresses.firstWhere((a) => a.id == addressId, orElse: () => _selectedAddress!);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
}
