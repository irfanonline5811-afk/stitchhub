import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ReferralService {
  final _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<String> getOrCreateReferralCode(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select('referral_code')
          .eq('id', userId)
          .single();

      if (data['referral_code'] != null && (data['referral_code'] as String).isNotEmpty) {
        return data['referral_code'] as String;
      }
      
      final code = _generateCode();
      await _supabase.from('users').update({
        'referral_code': code,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      return code;
    } catch (e) {
      // If user profile doesn't exist yet, this might fail, but let's rethrow or handle
      final code = _generateCode();
      return code;
    }
  }

  String _generateCode() {
    final raw = _uuid.v4().split('-').first.toUpperCase();
    return raw;
  }
}
