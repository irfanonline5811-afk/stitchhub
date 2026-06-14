class AddressModel {
  final String id;
  final String userId;
  final String label; // Home, Work, etc.
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? map['userId'] ?? '',
      label: map['label'] ?? '',
      addressLine1: map['address_line1'] ?? map['addressLine1'] ?? '',
      addressLine2: map['address_line2'] ?? map['addressLine2'],
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      postalCode: map['postal_code'] ?? map['postalCode'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isDefault: map['is_default'] ?? map['isDefault'] ?? false,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'].toString())
          : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
