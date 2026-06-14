import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class AppLauncherUtils {
  static const MethodChannel _channel = MethodChannel('com.example.stitchhub/app_launcher');

  /// Checks if an app is installed on Android (by package name).
  /// On iOS, always returns false.
  static Future<bool> isAppInstalled(String packageName) async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final bool installed = await _channel.invokeMethod('isAppInstalled', {
        'packageName': packageName,
      });
      return installed;
    } catch (e) {
      debugPrint('Error checking app installation: $e');
      return false;
    }
  }

  /// Launches an app on Android (by package name) or custom scheme on iOS.
  static Future<bool> launchApp({
    required String packageName,
    required String iosScheme,
  }) async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      try {
        final bool launched = await _channel.invokeMethod('launchApp', {
          'packageName': packageName,
        });
        return launched;
      } catch (e) {
        debugPrint('Error launching app via package manager: $e');
        return false;
      }
    } else if (Platform.isIOS) {
      try {
        final Uri appUri = Uri.parse(iosScheme);
        return await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('Error launching app via iOS scheme: $e');
        return false;
      }
    }
    return false;
  }
}
