import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/manual_payment_model.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../services/manual_payment_service.dart';
import '../../utils/url_utils.dart';
import 'manual_instructions_screen.dart';

class ManualPaymentPendingScreen extends StatefulWidget {
  final ManualPaymentModel payment;
  final OrderModel order;

  const ManualPaymentPendingScreen({
    super.key,
    required this.payment,
    required this.order,
  });

  @override
  State<ManualPaymentPendingScreen> createState() => _ManualPaymentPendingScreenState();
}

class _ManualPaymentPendingScreenState extends State<ManualPaymentPendingScreen> {
  final ManualPaymentService _paymentService = ManualPaymentService();
  late ManualPaymentModel _currentPayment;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _currentPayment = widget.payment;
    _startRealtimeListener();
  }

  @override
  void dispose() {
    _stopRealtimeListener();
    super.dispose();
  }

  void _startRealtimeListener() {
    _realtimeChannel = _paymentService.listenToPaymentStatus(
      _currentPayment.id,
      (updatedPayment) {
        if (mounted) {
          setState(() {
            _currentPayment = updatedPayment;
          });
          
          // Action on status transition
          if (updatedPayment.status == 'approved') {
            _showStatusNotification(
              title: 'Payment Approved!',
              message: 'Your payment proof has been verified. The tailor is starting work!',
              color: AppTheme.success,
              onClose: () => Navigator.of(context).popUntil((route) => route.isFirst),
            );
          } else if (updatedPayment.status == 'rejected') {
            _showStatusNotification(
              title: 'Payment Proof Rejected!',
              message: 'Unfortunately, your payment verification failed. Please check details or retry.',
              color: AppTheme.error,
              onClose: () {
                // Return back to instructions so they can retry
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ManualInstructionsScreen(
                      order: widget.order,
                      paymentMethod: widget.payment.paymentMethod,
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  void _stopRealtimeListener() {
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
  }

  void _showStatusNotification({
    required String title,
    required String message,
    required Color color,
    required VoidCallback onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              title.contains('Approved') ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              onClose();
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String walletTitle = _currentPayment.paymentMethod == 'jazzcash' ? 'JazzCash' : 'easypaisa';
    
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Payment Under Review'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.home_rounded),
            tooltip: 'Go to Home',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Icon Box Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.pending_actions_rounded, color: Colors.orange[800], size: 56),
                    ),
                    const SizedBox(height: AppTheme.spacing20),
                    const Text(
                      'Verification In Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    const Text(
                      'Your manual payment proof has been submitted. The tailor/admin is currently reviewing your transaction details. Usually completes in 10-30 minutes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.gray600, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),

            // Submitted details Card
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
                    const Text(
                      'Submitted Payment Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    
                    _buildPendingDetail('Order ID', '#${widget.order.id.substring(0, 8).toUpperCase()}'),
                    const Divider(height: 24),
                    _buildPendingDetail('Payment Wallet', walletTitle),
                    const Divider(height: 24),
                    _buildPendingDetail('Transaction TID', _currentPayment.transactionId ?? 'Not Entered'),
                    const Divider(height: 24),
                    _buildPendingDetail('Total Paid Amount', 'Rs. ${_currentPayment.amount.toStringAsFixed(0)}', isPrimary: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Real-time Loading Status indicator
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Text(
                  'Waiting for real-time verification status...',
                  style: TextStyle(color: AppTheme.gray600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing32),

            // Help Support WhatsApp Button
            OutlinedButton.icon(
              onPressed: () {
                UrlUtils.openWhatsApp(
                  '+923001234567',
                  'Hi StitchHub, I submitted the payment proof (TID: ${_currentPayment.transactionId}) for Order #${widget.order.id.substring(0,8).toUpperCase()}. Could you please review and approve it?',
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.green),
              label: const Text('Message Support on WhatsApp'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingDetail(String label, String value, {bool isPrimary = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.gray600, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: isPrimary ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isPrimary ? AppTheme.primaryGreen : AppTheme.gray900,
          ),
        ),
      ],
    );
  }
}
