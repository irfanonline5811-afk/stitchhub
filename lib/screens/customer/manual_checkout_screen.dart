import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import 'manual_instructions_screen.dart';
import '../../providers/order_provider.dart';
import 'package:provider/provider.dart';

class ManualCheckoutScreen extends StatefulWidget {
  final OrderModel order;

  const ManualCheckoutScreen({
    super.key,
    required this.order,
  });

  @override
  State<ManualCheckoutScreen> createState() => _ManualCheckoutScreenState();
}

class _ManualCheckoutScreenState extends State<ManualCheckoutScreen> {
  String _selectedMethod = 'jazzcash'; // 'jazzcash', 'easypaisa', 'cod'
  bool _isProcessing = false;

  void _handleCheckout() async {
    if (_selectedMethod == 'cod') {
      setState(() {
        _isProcessing = true;
      });

      try {
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
        // Complete checkout with Cash on Delivery
        await orderProvider.updateOrderPaymentStatus(widget.order.id, PaymentStatus.pending);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully with Cash on Delivery!'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } else {
      // Navigate to Payment Instructions Screen for JazzCash/easypaisa
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ManualInstructionsScreen(
            order: widget.order,
            paymentMethod: _selectedMethod,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Summary Card
            Card(
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Order ID', style: TextStyle(color: AppTheme.gray600)),
                        Text(
                          '#${order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.gray900),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Service Type', style: TextStyle(color: AppTheme.gray600)),
                        Text(
                          order.serviceType,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.gray900),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    const Divider(),
                    const SizedBox(height: AppTheme.spacing12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                        ),
                        Text(
                          'Rs. ${order.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            
            // Payment Method Selection Header
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // JazzCash Option
            _buildPaymentMethodTile(
              id: 'jazzcash',
              title: 'JazzCash Mobile Wallet',
              iconPath: Icons.account_balance_wallet,
              color: Colors.red[700]!,
            ),
            const SizedBox(height: AppTheme.spacing12),

            // EasyPaisa Option
            _buildPaymentMethodTile(
              id: 'easypaisa',
              title: 'easypaisa Mobile Wallet',
              iconPath: Icons.wallet_membership,
              color: Colors.green[700]!,
            ),
            const SizedBox(height: AppTheme.spacing12),

            // COD Option
            _buildPaymentMethodTile(
              id: 'cod',
              title: 'Cash on Delivery (COD)',
              iconPath: Icons.local_shipping_outlined,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(height: AppTheme.spacing32),

            // Pay / Continue Button
            ElevatedButton(
              onPressed: _isProcessing ? null : _handleCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                      ),
                    )
                  : Text(
                      _selectedMethod == 'cod' ? 'Place COD Order' : 'Proceed to Payment',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String id,
    required String title,
    required IconData iconPath,
    required Color color,
  }) {
    bool isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.gray300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconPath, color: color),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: AppTheme.gray900,
                ),
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedMethod,
              activeColor: AppTheme.primaryGreen,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMethod = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
