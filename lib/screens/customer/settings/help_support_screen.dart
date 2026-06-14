import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/modern_ui_components.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          children: [
            const ModernSectionHeader(title: 'Contact Us'),
            ModernCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined,
                        color: AppTheme.primaryGreen),
                    title: const Text('Email Support'),
                    subtitle: const Text('support@stitchhub.com'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Opening email client...')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined,
                        color: AppTheme.primaryGreen),
                    title: const Text('Call Us'),
                    subtitle: const Text('+1 234 567 8900'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling support...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            const ModernSectionHeader(title: 'Frequently Asked Questions'),
            _buildFAQItem('How do I track my order?',
                'You can track your order status in real-time from the "Orders" tab.'),
            _buildFAQItem('Can I cancel an order?',
                'Yes, you can cancel an order if it is still in "Pending" status.'),
            _buildFAQItem('How do I contact a tailor?',
                'You can use the built-in chat feature to communicate directly with tailors.'),
            const SizedBox(height: AppTheme.spacing24),
            ModernButton(
              text: 'Send Feedback',
              icon: Icons.feedback_outlined,
              isOutlined: true,
              onPressed: () {
                _showFeedbackDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(color: AppTheme.gray600),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Tell us how we can improve...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
