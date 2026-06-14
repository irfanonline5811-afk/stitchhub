import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../models/order_model.dart';
import '../../models/tailor_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/url_utils.dart';
import '../../utils/app_launcher_utils.dart';
import 'manual_upload_screenshot_screen.dart';

class ManualInstructionsScreen extends StatefulWidget {
  final OrderModel order;
  final String paymentMethod; // 'jazzcash' or 'easypaisa'

  const ManualInstructionsScreen({
    super.key,
    required this.order,
    required this.paymentMethod,
  });

  @override
  State<ManualInstructionsScreen> createState() => _ManualInstructionsScreenState();
}

class _ManualInstructionsScreenState extends State<ManualInstructionsScreen> {
  TailorModel? _tailor;
  bool _isLoadingTailor = true;

  @override
  void initState() {
    super.initState();
    _fetchTailorProfile();
  }

  Future<void> _fetchTailorProfile() async {
    try {
      final tailor = await AuthService().getTailorProfile(widget.order.tailorId);
      if (mounted) {
        setState(() {
          _tailor = tailor;
          _isLoadingTailor = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading tailor profile: $e');
      if (mounted) {
        setState(() {
          _isLoadingTailor = false;
        });
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account number copied to clipboard!'),
        backgroundColor: AppTheme.success,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _openWalletApp() async {
    final String appName = widget.paymentMethod == 'jazzcash' ? 'JazzCash' : 'EasyPaisa';
    final String package = widget.paymentMethod == 'jazzcash'
        ? 'com.techlogix.mobilinkcustomer'
        : 'pk.com.telenor.phoenix';
    final String playStoreUrl = widget.paymentMethod == 'jazzcash'
        ? 'https://play.google.com/store/apps/details?id=com.techlogix.mobilinkcustomer'
        : 'https://play.google.com/store/apps/details?id=pk.com.telenor.phoenix';
    final String appStoreUrl = widget.paymentMethod == 'jazzcash'
        ? 'https://apps.apple.com/pk/app/jazzcash/id1089079145'
        : 'https://apps.apple.com/pk/app/easypaisa-payments-made-easy/id1136450635';
    final String scheme = widget.paymentMethod == 'jazzcash' ? 'jazzcash://' : 'easypaisa://';

    try {
      final bool launched = await AppLauncherUtils.launchApp(
        packageName: package,
        iosScheme: scheme,
      );

      if (!launched) {
        throw Exception('Could not launch deep-link natively');
      }
    } catch (e) {
      debugPrint('Error launching $appName app: $e');
      if (mounted) {
        _showAppNotInstalledDialog(appName, playStoreUrl, appStoreUrl);
      }
    }
  }

  void _showAppNotInstalledDialog(String appName, String playStoreUrl, String appStoreUrl) {
    final Color themeColor = widget.paymentMethod == 'jazzcash' ? Colors.red[700]! : Colors.green[700]!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.app_blocking_rounded,
                    color: themeColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$appName App Not Found',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'It looks like the $appName app is not installed on your device. You can download it from the store or proceed with the payment manually.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Pay Manually',
                          style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final String url = Platform.isAndroid ? playStoreUrl : appStoreUrl;
                          final Uri storeUri = Uri.parse(url);
                          if (await canLaunchUrl(storeUri)) {
                            await launchUrl(storeUri, mode: LaunchMode.externalApplication);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Download App',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String walletTitle = widget.paymentMethod == 'jazzcash' ? 'JazzCash' : 'easypaisa';
    final Color themeColor = widget.paymentMethod == 'jazzcash' ? Colors.red[700]! : Colors.green[700]!;

    if (_isLoadingTailor) {
      return Scaffold(
        backgroundColor: AppTheme.gray50,
        appBar: AppBar(
          title: Text('$walletTitle Instructions'),
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
              SizedBox(height: 16),
              Text('Loading tailor payment credentials...', style: TextStyle(color: AppTheme.gray600)),
            ],
          ),
        ),
      );
    }

    // Determine credentials based on tailor configuration with system default fallbacks
    String accountNumber = '03001234567'; // Default System Fallback
    String accountTitle = 'StitchHub Tailors PVT'; // Default System Fallback
    bool isTailorDirect = false;

    if (_tailor != null) {
      if (widget.paymentMethod == 'jazzcash') {
        if (_tailor!.jazzcashNumber != null && _tailor!.jazzcashNumber!.isNotEmpty) {
          accountNumber = _tailor!.jazzcashNumber!;
          accountTitle = _tailor!.jazzcashTitle ?? _tailor!.businessName ?? _tailor!.name;
          isTailorDirect = true;
        }
      } else {
        if (_tailor!.easypaisaNumber != null && _tailor!.easypaisaNumber!.isNotEmpty) {
          accountNumber = _tailor!.easypaisaNumber!;
          accountTitle = _tailor!.easypaisaTitle ?? _tailor!.businessName ?? _tailor!.name;
          isTailorDirect = true;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: Text('$walletTitle Instructions'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions Card
            Card(
              elevation: 3,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.info_outline, color: themeColor, size: 40),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    Text(
                      'Transfer Amount via $walletTitle',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      isTailorDirect
                          ? 'Please transfer the exact amount directly to the tailor\'s wallet, copy the transaction ID, and take a screenshot.'
                          : 'Please transfer the exact amount shown below to our merchant wallet, copy the transaction ID, and take a screenshot.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.gray600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),

            // Account Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                        ),
                        if (isTailorDirect)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Pay Tailor Directly',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    
                    // Account Title
                    _buildDetailRow('Account Title', accountTitle),
                    const Divider(height: 24),

                    // Account Number (with COPY button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Account Number', style: TextStyle(color: AppTheme.gray600, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              accountNumber,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => _copyToClipboard(context, accountNumber),
                          icon: const Icon(Icons.copy_rounded, color: AppTheme.primaryGreen),
                          tooltip: 'Copy Number',
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Amount
                    _buildDetailRow('Required Amount', 'Rs. ${widget.order.price.toStringAsFixed(0)}', isPrimary: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Open Mobile Wallet App Deep link Button
            ElevatedButton.icon(
              onPressed: _openWalletApp,
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text('Open $walletTitle App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),

            // WhatsApp Support Button for inquiry
            OutlinedButton.icon(
              onPressed: () {
                UrlUtils.openWhatsApp(
                  '+923001234567',
                  'Hello StitchHub, I am facing some issues while making manual payment of Rs. ${widget.order.price.toStringAsFixed(0)} for Order #${widget.order.id.substring(0,8).toUpperCase()}. Please assist.',
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
              label: const Text('Contact Customer Support (WhatsApp)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Continue to Submit Proof Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ManualUploadScreenshotScreen(
                      order: widget.order,
                      paymentMethod: widget.paymentMethod,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('I Have Paid, Next', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.gray600, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isPrimary ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: isPrimary ? AppTheme.primaryGreen : AppTheme.gray900,
          ),
        ),
      ],
    );
  }
}
