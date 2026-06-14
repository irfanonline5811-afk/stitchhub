import 'dart:convert';
import 'user_model.dart';

class TailorModel extends UserModel {
  final String? businessName;
  final String? businessAddress;
  final double latitude;
  final double longitude;
  final List<String> specialties;
  final List<String> workSamples;
  final Map<String, double> pricing; // service type -> price
  final List<String> availableDays; // ['monday', 'tuesday', etc.]
  final String startTime; // "09:00"
  final String endTime; // "18:00"
  final double rating;
  final int totalReviews;
  final bool isAvailable;
  final String? description;
  final List<String> services; // ['shirt', 'pants', 'dress', etc.]
  final String? basePrice;
  final String? jazzcashNumber;
  final String? jazzcashTitle;
  final String? easypaisaNumber;
  final String? easypaisaTitle;

  TailorModel({
    required super.id,
    required super.email,
    required super.name,
    required super.phone,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    this.businessName,
    this.businessAddress,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.specialties = const [],
    this.workSamples = const [],
    this.pricing = const {},
    this.availableDays = const [],
    this.startTime = "09:00",
    this.endTime = "18:00",
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isAvailable = true,
    this.description,
    this.services = const [],
    this.basePrice,
    this.jazzcashNumber,
    this.jazzcashTitle,
    this.easypaisaNumber,
    this.easypaisaTitle,
  }) : super(userType: 'tailor');

  factory TailorModel.fromMap(Map<String, dynamic> map) {
    // Helper to safely parse lists from either String or List
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (e) {
          return [value]; // Fallback
        }
      }
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    // Helper to safely parse maps from either String or Map
    Map<String, double> parsePricingMap(dynamic value) {
      if (value == null) return {};
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is Map) {
            return decoded.map((key, val) => MapEntry(key.toString(), double.tryParse(val.toString()) ?? 0.0));
          }
        } catch (e) {
          return {};
        }
      }
      if (value is Map) {
         return value.map((key, val) => MapEntry(key.toString(), double.tryParse(val.toString()) ?? 0.0));
      }
      return {};
    }

    return TailorModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      profileImageUrl: map['profile_image_url']?.toString() ?? map['profileImageUrl']?.toString(),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.fromMillisecondsSinceEpoch(int.tryParse(map['createdAt']?.toString() ?? '0') ?? 0),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'].toString())
          : DateTime.fromMillisecondsSinceEpoch(int.tryParse(map['updatedAt']?.toString() ?? '0') ?? 0),
      businessName: map['business_name']?.toString() ?? map['businessName']?.toString(),
      businessAddress: map['business_address']?.toString() ?? map['businessAddress']?.toString(),
      latitude: double.tryParse(map['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(map['longitude']?.toString() ?? '0.0') ?? 0.0,
      specialties: parseList(map['specialties']),
      workSamples: parseList(map['work_samples'] ?? map['workSamples']),
      pricing: parsePricingMap(map['pricing']),
      availableDays: parseList(map['available_days'] ?? map['availableDays']),
      startTime: map['start_time']?.toString() ?? map['startTime']?.toString() ?? "09:00",
      endTime: map['end_time']?.toString() ?? map['endTime']?.toString() ?? "18:00",
      rating: double.tryParse(map['rating']?.toString() ?? '0.0') ?? 0.0,
      totalReviews: int.tryParse(map['total_reviews']?.toString() ?? map['totalReviews']?.toString() ?? '0') ?? 0,
      isAvailable: map['is_available'] == true || map['is_available'] == 'true' || map['isAvailable'] == true,
      description: map['description']?.toString(),
      services: parseList(map['services']),
      basePrice: map['base_price']?.toString() ?? map['basePrice']?.toString(),
      jazzcashNumber: map['jazzcash_number']?.toString() ?? map['jazzcashNumber']?.toString(),
      jazzcashTitle: map['jazzcash_title']?.toString() ?? map['jazzcashTitle']?.toString(),
      easypaisaNumber: map['easypaisa_number']?.toString() ?? map['easypaisaNumber']?.toString(),
      easypaisaTitle: map['easypaisa_title']?.toString() ?? map['easypaisaTitle']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'business_name': businessName,
      'business_address': businessAddress,
      'latitude': latitude,
      'longitude': longitude,
      'specialties': specialties,
      'work_samples': workSamples,
      'pricing': pricing,
      'available_days': availableDays,
      'start_time': startTime,
      'end_time': endTime,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_available': isAvailable,
      'description': description,
      'services': services,
      'base_price': basePrice,
      'jazzcash_number': jazzcashNumber,
      'jazzcash_title': jazzcashTitle,
      'easypaisa_number': easypaisaNumber,
      'easypaisa_title': easypaisaTitle,
    });
    return map;
  }

  TailorModel copyWithTailor({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? businessName,
    String? businessAddress,
    double? latitude,
    double? longitude,
    List<String>? specialties,
    List<String>? workSamples,
    Map<String, double>? pricing,
    List<String>? availableDays,
    String? startTime,
    String? endTime,
    double? rating,
    int? totalReviews,
    bool? isAvailable,
    String? description,
    List<String>? services,
    String? basePrice,
    String? jazzcashNumber,
    String? jazzcashTitle,
    String? easypaisaNumber,
    String? easypaisaTitle,
  }) {
    return TailorModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      specialties: specialties ?? this.specialties,
      workSamples: workSamples ?? this.workSamples,
      pricing: pricing ?? this.pricing,
      availableDays: availableDays ?? this.availableDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
      services: services ?? this.services,
      basePrice: basePrice ?? this.basePrice,
      jazzcashNumber: jazzcashNumber ?? this.jazzcashNumber,
      jazzcashTitle: jazzcashTitle ?? this.jazzcashTitle,
      easypaisaNumber: easypaisaNumber ?? this.easypaisaNumber,
      easypaisaTitle: easypaisaTitle ?? this.easypaisaTitle,
    );
  }
}
