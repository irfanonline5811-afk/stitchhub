import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/manual_payment_model.dart';
import '../../theme/app_theme.dart';
import '../../services/manual_payment_service.dart';
import '../../providers/auth_provider.dart';
import 'manual_payment_details_screen.dart';

class ManualPaymentsListScreen extends StatefulWidget {
  const ManualPaymentsListScreen({super.key});

  @override
  State<ManualPaymentsListScreen> createState() => _ManualPaymentsListScreenState();
}

class _ManualPaymentsListScreenState extends State<ManualPaymentsListScreen> {
  final ManualPaymentService _paymentService = ManualPaymentService();
  List<ManualPaymentModel> _payments = [];
  List<ManualPaymentModel> _filteredPayments = [];
  bool _isLoading = true;
  String _selectedStatusFilter = 'all'; // 'all', 'pending', 'approved', 'rejected'

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final payments = await _paymentService.getTailorManualPayments(authProvider.user!.id);
        if (mounted) {
          setState(() {
            _payments = payments;
            _applyFilter();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching tailor payments: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    if (_selectedStatusFilter == 'all') {
      _filteredPayments = _payments;
    } else {
      _filteredPayments = _payments.where((p) => p.status == _selectedStatusFilter).toList();
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'approved') return AppTheme.success;
    if (status == 'rejected') return AppTheme.error;
    return Colors.orange[700]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Incoming Payments'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchPayments,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12, horizontal: AppTheme.spacing16),
            color: AppTheme.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterChip('all', 'All'),
                _buildFilterChip('pending', 'Pending'),
                _buildFilterChip('approved', 'Approved'),
                _buildFilterChip('rejected', 'Rejected'),
              ],
            ),
          ),

          // Payments List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                    ),
                  )
                : _filteredPayments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payment_outlined, size: 64, color: AppTheme.gray400),
                            SizedBox(height: AppTheme.spacing16),
                            Text(
                              'No manual payments found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        itemCount: _filteredPayments.length,
                        itemBuilder: (context, index) {
                          final payment = _filteredPayments[index];
                          final String walletTitle = payment.paymentMethod == 'jazzcash' ? 'JazzCash' : 'easypaisa';
                          final Color statusColor = _getStatusColor(payment.status);

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ManualPaymentDetailsScreen(payment: payment),
                                  ),
                                );
                                // Refresh list if a payment status is updated
                                if (result == true) {
                                  _fetchPayments();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(AppTheme.spacing16),
                                child: Row(
                                  children: [
                                    // Payment Method Avatar Icon
                                    CircleAvatar(
                                      backgroundColor: payment.paymentMethod == 'jazzcash'
                                          ? Colors.red[50]
                                          : Colors.green[50],
                                      child: Icon(
                                        Icons.monetization_on_rounded,
                                        color: payment.paymentMethod == 'jazzcash'
                                            ? Colors.red[700]
                                            : Colors.green[700],
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spacing16),

                                    // Payment info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            payment.customerName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Order ID: #${payment.orderId.substring(0, 8).toUpperCase()}',
                                            style: const TextStyle(color: AppTheme.gray600, fontSize: 13),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                                ),
                                                child: Text(
                                                  payment.status.toUpperCase(),
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'via $walletTitle',
                                                style: const TextStyle(color: AppTheme.gray500, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Amount
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Rs. ${payment.amount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${payment.createdAt.day}/${payment.createdAt.month}',
                                          style: const TextStyle(color: AppTheme.gray400, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterId, String label) {
    bool isSelected = _selectedStatusFilter == filterId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatusFilter = filterId;
            _applyFilter();
          });
        }
      },
      selectedColor: AppTheme.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.white : AppTheme.gray700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppTheme.gray100,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
    );
  }
}
