import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../providers/language_provider.dart';
import '../../widgets/modern_ui_components.dart';
import '../../theme/app_theme.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    debugPrint('MyOrdersScreen: _loadOrders called. user: ${authProvider.user?.id}');

    // If it's already loading when user clicks refresh, force a reset first
    if (orderProvider.isLoading) {
      orderProvider.forceResetLoading();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (authProvider.user != null) {
      await orderProvider.fetchCustomerOrders(authProvider.user!.id);
    }
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
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
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

          if (orderProvider.customerOrders.isEmpty) {
            return ModernEmptyState(
              icon: Icons.shopping_bag_outlined,
              title: languageProvider.translate('no_orders_yet'),
              subtitle: languageProvider.translate('place_first_order'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            color: AppTheme.primaryGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: orderProvider.customerOrders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.customerOrders[index];
                return AnimatedFadeIn(
                  delay: index * 0.1,
                  child: _OrderCard(
                    order: order,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(order: order),
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
              // Service Icon
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
                            order.tailorName,
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
          if (order.status == OrderStatus.completed &&
              order.rating == null) ...[
            const SizedBox(height: AppTheme.spacing12),
            ModernButton(
              text: languageProvider.translate('rate_and_review'),
              icon: Icons.star_outline_rounded,
              onPressed: () {
                _showRatingDialog(context, order, languageProvider);
              },
              isOutlined: true,
              height: 48,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showRatingDialog(BuildContext context, OrderModel order, LanguageProvider languageProvider) {
    double rating = 0.0;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
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
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: AppTheme.primaryGreen,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing20),
                Text(
                  languageProvider.translate('rate_and_review'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gray900,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  languageProvider.translate('how_was_experience'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          rating = (index + 1).toDouble();
                        });
                      },
                      child: AnimatedContainer(
                        duration: AppTheme.durationFast,
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppTheme.accentAmber,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppTheme.spacing24),
                ModernTextField(
                  controller: reviewController,
                  labelText: languageProvider.translate('write_review'),
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
                        text: languageProvider.translate('submit'),
                        icon: Icons.check_rounded,
                        onPressed: rating > 0
                            ? () {
                                final orderProvider =
                                    Provider.of<OrderProvider>(context,
                                        listen: false);
                                orderProvider.addOrderReview(
                                  order.id,
                                  rating,
                                  reviewController.text,
                                );
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        languageProvider.translate('thank_you_review')),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMedium),
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

