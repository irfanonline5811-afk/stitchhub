import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/modern_ui_components.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Local state for notification preferences
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _chatMessages = true;
  bool _appUpdates = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _orderUpdates = prefs.getBool('notifications_order_updates') ?? true;
        _chatMessages = prefs.getBool('notifications_chat_messages') ?? true;
        _promotions = prefs.getBool('notifications_promotions') ?? false;
        _appUpdates = prefs.getBool('notifications_app_updates') ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                children: [
                  _buildNotificationSwitch(
                    title: 'Order Updates',
                    subtitle: 'Get notified when your order status changes',
                    value: _orderUpdates,
                    onChanged: (value) {
                      setState(() => _orderUpdates = value);
                      _savePreference('notifications_order_updates', value);
                    },
                  ),
                  _buildNotificationSwitch(
                    title: 'Chat Messages',
                    subtitle:
                        'Receive notifications for new messages from tailors',
                    value: _chatMessages,
                    onChanged: (value) {
                      setState(() => _chatMessages = value);
                      _savePreference('notifications_chat_messages', value);
                    },
                  ),
                  _buildNotificationSwitch(
                    title: 'Promotions & Offers',
                    subtitle: 'Receive updates on discounts and special offers',
                    value: _promotions,
                    onChanged: (value) {
                      setState(() => _promotions = value);
                      _savePreference('notifications_promotions', value);
                    },
                  ),
                  _buildNotificationSwitch(
                    title: 'App Updates',
                    subtitle:
                        'Get notified about new features and improvements',
                    value: _appUpdates,
                    onChanged: (value) {
                      setState(() => _appUpdates = value);
                      _savePreference('notifications_app_updates', value);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.gray900,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.gray600,
              fontSize: 13,
            ),
          ),
          activeColor: AppTheme.primaryGreen,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      ),
    );
  }
}
