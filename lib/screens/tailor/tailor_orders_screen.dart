import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../providers/language_provider.dart';
import '../../widgets/modern_ui_components.dart';
import '../../theme/app_theme.dart';
import 'order_detail_screen.dart';

class TailorOrdersScreen extends StatefulWidget {
  const TailorOrdersScreen({super.key});

  @override
  State<TailorOrdersScreen> createState() => _TailorOrdersScreenState();
}

class _TailorOrdersScreenState extends State<TailorOrdersScreen> {
  OrderStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    debugPrint('TailorOrdersScreen: _loadOrders called. user: ${authProvider.user?.id}');
    
    // If it's already loading when user clicks refresh, force a reset first
    if (orderProvider.isLoading) {
      orderProvider.forceResetLoading();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (authProvider.user != null) {
      await orderProvider.fetchTailorOrders(authProvider.user!.id);
    } else {
      // If user is null, wait a bit and try again once
      debugPrint('TailorOrdersScreen: User is null, retrying in 2 seconds...');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted && authProvider.user != null) {
        await orderProvider.fetchTailorOrders(authProvider.user!.id);
      }
    }
  }

  List<OrderModel> _getFilteredOrders(List<OrderModel> orders) {
    if (_selectedFilter == null) return orders;
    return orders.where((order) => order.status == _selectedFilter).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: Text(languageProvider.translate('my_orders')),
        elevation: 0,
        actions: [
          PopupMenuButton<OrderStatus?>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: languageProvider.translate('filter_orders'),
            onSelected: (status) {
              setState(() {
                _selectedFilter = status;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Text(languageProvider.translate('all_orders')),
              ),
              PopupMenuItem(
                value: OrderStatus.pending,
                child: Text(languageProvider.translate('status_pending')),
              ),
              PopupMenuItem(
                value: OrderStatus.confirmed,
                child: Text(languageProvider.translate('status_confirmed')),
              ),
              PopupMenuItem(
                value: OrderStatus.inProgress,
                child: Text(languageProvider.translate('status_in_progress')),
              ),
              PopupMenuItem(
                value: OrderStatus.cutting,
                child: Text(languageProvider.translate('status_cutting')),
              ),
              PopupMenuItem(
                value: OrderStatus.stitching,
                child: Text(languageProvider.translate('status_stitching')),
              ),
              PopupMenuItem(
                value: OrderStatus.readyForPickup,
                child: Text(languageProvider.translate('status_ready')),
              ),
              PopupMenuItem(
                value: OrderStatus.completed,
                child: Text(languageProvider.translate('status_completed')),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            );
          }

          if (orderProvider.error != null) {
            return ModernEmptyState(
              icon: Icons.error_outline_rounded,
              title: languageProvider.translate('error_loading_orders'),
              subtitle: orderProvider.error,
              buttonText: languageProvider.translate('retry'),
              onButtonTap: _loadOrders,
            );
          }

          final filteredOrders = _getFilteredOrders(orderProvider.tailorOrders);

          if (filteredOrders.isEmpty) {
            return ModernEmptyState(
              icon: Icons.shopping_bag_outlined,
              title: _selectedFilter == null
                  ? languageProvider.translate('no_orders_yet')
                  : 'No ${_selectedFilter.toString().split('.').last.toLowerCase()} orders',
              subtitle: languageProvider.translate('orders_appear_here'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            color: AppTheme.primaryGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return AnimatedFadeIn(
                  delay: index * 0.1,
                  child: _OrderCard(
                    order: order,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TailorOrderDetailScreen(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return ModernCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    order.serviceType[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            order.serviceType,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gray900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusChip(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: AppTheme.gray600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.customerName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.translate('total_price'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      languageProvider.translate('order_date'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppTheme.gray600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(order.orderDate),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.gray700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (order.status == OrderStatus.pending) ...[
            const SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: languageProvider.translate('accept_order'),
                    icon: Icons.check_rounded,
                    onPressed: () {
                      _showConfirmDialog(context, order, languageProvider);
                    },
                    height: 48,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: ModernButton(
                    text: languageProvider.translate('reject_order'),
                    icon: Icons.close_rounded,
                    onPressed: () {
                      _showRejectDialog(context, order, languageProvider);
                    },
                    backgroundColor: AppTheme.error,
                    isOutlined: true,
                    height: 48,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showConfirmDialog(BuildContext context, OrderModel order, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            color: AppTheme.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.success,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppTheme.spacing20),
              Text(
                languageProvider.translate('confirm_order'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gray900,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                languageProvider.translate('sure_accept_order'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing24),
              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: languageProvider.translate('cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                      isOutlined: true,
                      backgroundColor: AppTheme.gray600,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: ModernButton(
                      text: languageProvider.translate('accept_order'),
                      icon: Icons.check_rounded,
                      onPressed: () {
                        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                        orderProvider.updateOrderStatus(order.id, OrderStatus.confirmed);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(languageProvider.translate('order_confirmed_success')),
                            backgroundColor: AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, OrderModel order, LanguageProvider languageProvider) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            color: AppTheme.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  color: AppTheme.error,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppTheme.spacing20),
              Text(
                languageProvider.translate('reject_order_title'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gray900,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                languageProvider.translate('provide_reject_reason'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing20),
              ModernTextField(
                controller: reasonController,
                labelText: languageProvider.translate('reason_for_rejection'),
                hintText: languageProvider.translate('enter_reason'),
                maxLines: 3,
                prefixIcon: Icons.edit_outlined,
              ),
              const SizedBox(height: AppTheme.spacing24),
              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: languageProvider.translate('cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                      isOutlined: true,
                      backgroundColor: AppTheme.gray600,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: ModernButton(
                      text: languageProvider.translate('reject_order'),
                      icon: Icons.close_rounded,
                      onPressed: () {
                        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                        orderProvider.updateOrderStatus(order.id, OrderStatus.cancelled);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(languageProvider.translate('order_rejected')),
                            backgroundColor: AppTheme.warning,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                        );
                      },
                      backgroundColor: AppTheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = AppTheme.warningLight;
        textColor = AppTheme.warning;
        text = languageProvider.translate('status_pending');
        break;
      case OrderStatus.confirmed:
        backgroundColor = AppTheme.infoLight;
        textColor = AppTheme.info;
        text = languageProvider.translate('status_confirmed');
        break;
      case OrderStatus.inProgress:
        backgroundColor = AppTheme.accentPurple.withValues(alpha: 0.2);
        textColor = AppTheme.accentPurple;
        text = languageProvider.translate('status_in_progress');
        break;
      case OrderStatus.cutting:
        backgroundColor = Colors.blue.withValues(alpha: 0.2);
        textColor = Colors.blue;
        text = languageProvider.translate('status_cutting');
        break;
      case OrderStatus.stitching:
        backgroundColor = Colors.indigo.withValues(alpha: 0.2);
        textColor = Colors.indigo;
        text = languageProvider.translate('status_stitching');
        break;
      case OrderStatus.qualityCheck:
        backgroundColor = Colors.teal.withValues(alpha: 0.2);
        textColor = Colors.teal;
        text = languageProvider.translate('status_quality_check');
        break;
      case OrderStatus.readyForPickup:
        backgroundColor = AppTheme.successLight;
        textColor = AppTheme.success;
        text = languageProvider.translate('status_ready');
        break;
      case OrderStatus.completed:
        backgroundColor = AppTheme.successLight;
        textColor = AppTheme.success;
        text = languageProvider.translate('status_completed');
        break;
      case OrderStatus.cancelled:
        backgroundColor = AppTheme.errorLight;
        textColor = AppTheme.error;
        text = languageProvider.translate('status_cancelled');
        break;
    }

    return ModernStatusBadge(
      status: text,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}




