import 'package:flutter/material.dart';
import '../../models/manual_payment_model.dart';
import '../../theme/app_theme.dart';
import '../../services/manual_payment_service.dart';

class ManualPaymentDetailsScreen extends StatefulWidget {
  final ManualPaymentModel payment;

  const ManualPaymentDetailsScreen({
    super.key,
    required this.payment,
  });

  @override
  State<ManualPaymentDetailsScreen> createState() => _ManualPaymentDetailsScreenState();
}

class _ManualPaymentDetailsScreenState extends State<ManualPaymentDetailsScreen> {
  final ManualPaymentService _paymentService = ManualPaymentService();
  bool _isProcessing = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.payment.status;
  }

  void _updateStatus(String newStatus) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await _paymentService.updatePaymentStatus(
        paymentId: widget.payment.id,
        orderId: widget.payment.orderId,
        status: newStatus,
      );

      setState(() {
        _currentStatus = newStatus;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successfully marked as $newStatus!'),
            backgroundColor: newStatus == 'approved' ? AppTheme.success : AppTheme.error,
          ),
        );
        Navigator.of(context).pop(true); // Return true to refresh list
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _viewFullscreenReceipt(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Receipt Screenshot'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text('Error loading screenshot image', style: TextStyle(color: Colors.white)),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final String walletTitle = payment.paymentMethod == 'jazzcash' ? 'JazzCash' : 'easypaisa';
    
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Payment Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment Status Header
            Card(
              color: _currentStatus == 'approved'
                  ? AppTheme.success.withValues(alpha: 0.1)
                  : _currentStatus == 'rejected'
                      ? AppTheme.error.withValues(alpha: 0.1)
                      : Colors.orange[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentStatus == 'approved'
                          ? Icons.check_circle_rounded
                          : _currentStatus == 'rejected'
                              ? Icons.cancel_rounded
                              : Icons.hourglass_empty_rounded,
                      color: _currentStatus == 'approved'
                          ? AppTheme.success
                          : _currentStatus == 'rejected'
                              ? AppTheme.error
                              : Colors.orange[800]!,
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Text(
                      'STATUS: ${_currentStatus.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _currentStatus == 'approved'
                            ? AppTheme.success
                            : _currentStatus == 'rejected'
                                ? AppTheme.error
                                : Colors.orange[800]!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Details card
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
                      'Transaction Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    
                    _buildDetailRow('Customer Name', payment.customerName),
                    const Divider(height: 24),
                    _buildDetailRow('Customer Phone', payment.customerPhone),
                    const Divider(height: 24),
                    _buildDetailRow('Payment Method', walletTitle),
                    const Divider(height: 24),
                    _buildDetailRow('Transaction TID', payment.transactionId ?? 'Not Entered'),
                    const Divider(height: 24),
                    _buildDetailRow('Transferred Amount', 'Rs. ${payment.amount.toStringAsFixed(0)}', isPrimary: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),

            // Screenshot receipt card
            if (payment.screenshotUrl != null) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing20),
                  child: Column(
                    children: [
                      const Text(
                        'Payment Screenshot Proof',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      const Text(
                        'Tap the image below to view fullscreen and zoom.',
                        style: TextStyle(color: AppTheme.gray600, fontSize: 12),
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      
                      InkWell(
                        onTap: () => _viewFullscreenReceipt(context, payment.screenshotUrl!),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        child: Container(
                          height: 240,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(color: AppTheme.gray200),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium - 1),
                            child: Image.network(
                              payment.screenshotUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Text('Failed to load image preview'));
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
            ],

            // Approve & Reject Buttons (Only visible if currently pending)
            if (_currentStatus == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : () => _updateStatus('rejected'),
                      icon: const Icon(Icons.cancel_outlined, color: AppTheme.error),
                      label: const Text('Reject Payment', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : () => _updateStatus('approved'),
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                      label: const Text('Approve Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrimary = false}) {
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
