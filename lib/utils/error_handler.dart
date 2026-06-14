import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      // Supabase Auth errors
      switch (error.message.toLowerCase()) {
        case 'invalid login credentials':
          return 'Incorrect email or password.';
        case 'user not found':
          return 'No user found with this email address.';
        case 'user already exists':
          return 'An account already exists with this email address.';
        case 'email not confirmed':
          return 'Please confirm your email address before logging in.';
        default:
          return error.message;
      }
    } else if (error is PostgrestException) {
      // Supabase Database errors
      return 'Database error: ${error.message}';
    } else if (error is StorageException) {
      // Supabase Storage errors
      return 'Storage error: ${error.message}';
    } else if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('network') || errorString.contains('timeout')) {
        return 'Network error. Please check your internet connection and try again.';
      } else if (errorString.contains('supabase')) {
        return 'Supabase service error. Please try again later.';
      } else {
        return error.toString();
      }
    } else {
      return error.toString();
    }
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
