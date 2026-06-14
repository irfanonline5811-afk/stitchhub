// This is a unit test suite for StitchHub data models.

import 'package:flutter_test/flutter_test.dart';
import 'package:stitchhub/models/user_model.dart';

void main() {
  group('UserModel Unit Tests', () {
    final now = DateTime.now();

    test('should correctly serialize to a map', () {
      final user = UserModel(
        id: 'user-123',
        email: 'test@example.com',
        name: 'John Doe',
        phone: '1234567890',
        userType: 'customer',
        createdAt: now,
        updatedAt: now,
      );

      final map = user.toMap();

      expect(map['id'], 'user-123');
      expect(map['email'], 'test@example.com');
      expect(map['name'], 'John Doe');
      expect(map['phone'], '1234567890');
      expect(map['user_type'], 'customer');
      expect(map['created_at'], now.toIso8601String());
      expect(map['updated_at'], now.toIso8601String());
    });

    test('should correctly deserialize from a map', () {
      final map = {
        'id': 'user-456',
        'email': 'jane@example.com',
        'name': 'Jane Smith',
        'phone': '0987654321',
        'user_type': 'tailor',
        'profile_image_url': 'https://example.com/profile.jpg',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final user = UserModel.fromMap(map);

      expect(user.id, 'user-456');
      expect(user.email, 'jane@example.com');
      expect(user.name, 'Jane Smith');
      expect(user.phone, '0987654321');
      expect(user.userType, 'tailor');
      expect(user.profileImageUrl, 'https://example.com/profile.jpg');
      expect(user.createdAt, DateTime.parse(now.toIso8601String()));
      expect(user.updatedAt, DateTime.parse(now.toIso8601String()));
    });

    test('should support copyWith operations', () {
      final user = UserModel(
        id: 'user-123',
        email: 'test@example.com',
        name: 'John Doe',
        phone: '1234567890',
        userType: 'customer',
        createdAt: now,
        updatedAt: now,
      );

      final copiedUser = user.copyWith(
        name: 'John Changed',
        userType: 'tailor',
      );

      expect(copiedUser.id, 'user-123');
      expect(copiedUser.email, 'test@example.com');
      expect(copiedUser.name, 'John Changed');
      expect(copiedUser.phone, '1234567890');
      expect(copiedUser.userType, 'tailor');
    });
  });
}
