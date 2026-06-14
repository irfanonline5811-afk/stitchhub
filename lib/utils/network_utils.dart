import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

  static Future<bool> isConnected() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity()
          .timeout(const Duration(seconds: 3));
      return !connectivityResults.contains(ConnectivityResult.none);
    } on TimeoutException catch (_) {
      return false;
    }
  }

  static Future<bool> checkConnectivity() async {
    try {
      final hasConnection = await isConnected();
      if (!hasConnection) return false;
      
      if (kIsWeb) return true; // Bypass InternetAddress.lookup on Web platforms
      return await hasInternetConnection();
    } catch (e) {
      debugPrint('Network check error: $e');
      return false;
    }
  }
}
