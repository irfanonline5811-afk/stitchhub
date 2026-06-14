import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/modern_ui_components.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Privacy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          children: [
            ModernCard(
              onTap: () {
                // Navigate to Privacy Policy detail or show dialog
                _showPrivacyDialog(context, 'Privacy Policy');
              },
              child: const ListTile(
                leading:
                    Icon(Icons.policy_outlined, color: AppTheme.primaryGreen),
                title: Text('Privacy Policy'),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            ModernCard(
              onTap: () {
                _showPrivacyDialog(context, 'Terms of Service');
              },
              child: const ListTile(
                leading: Icon(Icons.description_outlined,
                    color: AppTheme.primaryGreen),
                title: Text('Terms of Service'),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            ModernCard(
              onTap: () {
                _showPrivacyDialog(context, 'Data Usage');
              },
              child: const ListTile(
                leading: Icon(Icons.data_usage, color: AppTheme.primaryGreen),
                title: Text('Data Usage'),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            ModernButton(
              text: 'Delete Account',
              icon: Icons.delete_forever,
              backgroundColor: AppTheme.error,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                        'Are you sure you want to delete your account? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          final ok = await auth.deleteAccount();
                          if (context.mounted) {
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Account successfully deleted')),
                              );
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(auth.error ?? 'Failed to delete account')),
                              );
                            }
                          }
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context, String title) {
    String content = '';
    if (title == 'Privacy Policy') {
      content = 'StitchHub is committed to protecting your privacy. We collect your email, phone number, physical location (GPS coordinates for nearby searches), profile photos, and device notification tokens.\n\nThis data is used solely to facilitate tailor search, bookings, push notifications, and measurement vault operations. All personal information is securely encrypted and is never sold to third parties.';
    } else if (title == 'Terms of Service') {
      content = 'By registering an account on StitchHub, you agree to conduct transactions and communication in good faith. StitchHub is a matching marketplace platform and is not responsible for fabric quality or individual tailor craftsmanship.\n\nAll fit and tailoring disputes must be resolved between both parties. Submission of fraudulent payment receipts or engaging in platform harassment is strictly prohibited and will result in immediate permanent account suspension.';
    } else if (title == 'Data Usage') {
      content = 'StitchHub uses Supabase Cloud Storage for hosting profile photos, portfolio images, and chat audio recordings. Location permission is used to compute tailors\' distances using the Haversine formula.\n\nLocal preferences, offline database caching, and language choices (Urdu/English) are stored locally on your device via Hive and SharedPreferences for optimal offline performance.';
    } else {
      content = 'Legal content placeholder.';
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 450),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 14, color: AppTheme.gray700, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 100,
                  height: 40,
                  child: ModernButton(
                    text: 'Close',
                    height: 40,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
