import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class UrlUtils {
  static Future<void> makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  static Future<void> openWhatsApp(String phoneNumber, String message) async {
    // Format number: remove +, spaces, and add country code if missing
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Default to PK (+92) if it starts with 0 and is 11 digits
    if (formattedNumber.startsWith('0') && formattedNumber.length == 11) {
      formattedNumber = '92${formattedNumber.substring(1)}';
    }

    String url = "";
    if (!kIsWeb && Platform.isAndroid) {
      url = "https://wa.me/$formattedNumber/?text=${Uri.encodeComponent(message)}";
    } else {
      url = "https://api.whatsapp.com/send?phone=$formattedNumber&text=${Uri.encodeComponent(message)}";
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
