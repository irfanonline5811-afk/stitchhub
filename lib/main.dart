import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/tailor_provider.dart';
import 'providers/order_provider.dart';
import 'providers/location_provider.dart';
import 'providers/measurement_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/review_provider.dart';
import 'providers/address_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/language_provider.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Global navigator key for navigation from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Main entry point

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for push notifications (only on mobile platforms to prevent web crash)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }
  
  // Initialize Hive for local caching
  await Hive.initFlutter();
  await Hive.openBox('app_cache');
  await Hive.openBox('offline_queue');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://nswatnzkmkscfpvltunn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zd2F0bnprbWtzY2Zwdmx0dW5uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzNzgyOTQsImV4cCI6MjA4ODk1NDI5NH0.U2NHh3T_Dw67rm0DfMVKcJeZjhl_2yTWq3WNNZ61ze8',
  );
  
  // Initialize notification service with navigator key
  final notificationService = NotificationService();
  await notificationService.initialize(navigatorKey: navigatorKey);
  
  // Initialize Offline-First Sync Service
  SyncService().initialize();
  
  runApp(const StitchHubApp());
}


class StitchHubApp extends StatelessWidget {
  const StitchHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TailorProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => MeasurementProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'StitchHub',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: languageProvider.currentLocale,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}



