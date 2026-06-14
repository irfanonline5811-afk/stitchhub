import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../models/order_tracking_model.dart';
import '../../providers/order_provider.dart';
import '../../services/order_tracking_service.dart';
import '../../services/payment_service.dart';
import '../../services/auth_service.dart';

import '../../utils/url_utils.dart';
import '../../models/user_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderTrackingService _trackingService = OrderTrackingService();
  final AuthService _authService = AuthService();
  List<OrderTrackingEvent> _trackingEvents = [];
  bool _isLoadingTracking = true;
  UserModel? _tailorUser; // To get the phone number

  @override
  void initState() {
    super.initState();
    _loadTrackingHistory();
    _loadTailorInfo();
  }

  Future<void> _loadTailorInfo() async {
    final user = await _authService.getUserProfile(widget.order.tailorId);
    if (mounted) {
      setState(() {
        _tailorUser = user;
      });
    }
  }

  Future<void> _loadTrackingHistory() async {
    try {
      final events = await _trackingService.getTrackingHistory(widget.order.id);
      if (mounted) {
        setState(() {
          _trackingEvents = events;
          _isLoadingTracking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTracking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 8)}'),
        actions: [
          if (order.status == OrderStatus.pending || order.status == OrderStatus.cancelled)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () => _showDeleteDialog(context),
              tooltip: 'Delete Permanently',
            ),
          if (order.status == OrderStatus.pending)
            TextButton(
              onPressed: () => _showCancelDialog(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: _getStatusColor(order.status),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(order.status),
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusText(order.status),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStatusDescription(order.status),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Estimated Delivery Time
            if (order.estimatedDeliveryDate != null && order.status != OrderStatus.completed && order.status != OrderStatus.cancelled)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        color: Colors.blue[700],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimated Delivery',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatEstimatedDelivery(order.estimatedDeliveryDate!),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (order.estimatedDeliveryDate != null && order.status != OrderStatus.completed && order.status != OrderStatus.cancelled)
              const SizedBox(height: 24),
            // Tracking Timeline
            const Text(
              'Order Tracking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTrackingTimeline(order),
            const SizedBox(height: 24),
            // Order Details
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Service Type',
              value: order.serviceType,
            ),
            _DetailRow(
              label: 'Description',
              value: order.description,
            ),
            _DetailRow(
              label: 'Price',
              value: 'Rs. ${order.price.toStringAsFixed(0)}',
            ),
            _DetailRow(
              label: 'Payment Method',
              value: order.paymentMethod.toString().split('.').last,
            ),
            _DetailRow(
              label: 'Order Date',
              value: _formatDate(order.orderDate),
            ),
            if (order.confirmedDate != null)
              _DetailRow(
                label: 'Confirmed Date',
                value: _formatDate(order.confirmedDate!),
              ),
            if (order.completedDate != null)
              _DetailRow(
                label: 'Completed Date',
                value: _formatDate(order.completedDate!),
              ),
            const SizedBox(height: 24),
            // Tailor Information
            const Text(
              'Tailor Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          child: Text(
                            order.tailorName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.tailorName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                order.tailorAddress ?? 'Address not provided',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _tailorUser != null ? () {
                                UrlUtils.makeCall(_tailorUser!.phone);
                              } : null,
                              icon: const Icon(Icons.phone),
                              label: const Text('Call'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _tailorUser != null ? () {
                                UrlUtils.openWhatsApp(
                                  _tailorUser!.phone, 
                                  "Hi ${order.tailorName}, I'm checking about my Order #${order.id.substring(0,8)}."
                                );
                              } : null,
                              icon: const Icon(Icons.message, size: 20, color: Colors.green),
                              label: const Text('WhatsApp', textAlign: TextAlign.center),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Images
            if (order.images.isNotEmpty) ...[
              const Text(
                'Reference Images',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: order.images.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order.images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            // Measurements
            if (order.measurements.isNotEmpty) ...[
              const Text(
                'Measurements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: order.measurements.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(entry.value.toString()),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Notes
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(order.notes!),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Review Section
            if (order.status == OrderStatus.completed) ...[
              if (order.rating != null) ...[
                const Text(
                  'Your Review',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < (order.rating ?? 0).round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${order.rating!.toStringAsFixed(1)}/5',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (order.review != null && order.review!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(order.review!),
                        ],
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  'Rate Your Experience',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showRatingDialog(context, order);
                    },
                    child: const Text('Rate & Review'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange[700]!;
      case OrderStatus.confirmed:
        return const Color(0xFF2E7D32); // Green
      case OrderStatus.inProgress:
        return const Color(0xFF2E7D32); // Green
      case OrderStatus.cutting:
        return const Color(0xFF2E7D32); // Green
      case OrderStatus.stitching:
        return const Color(0xFF2E7D32); // Green
      case OrderStatus.qualityCheck:
        return const Color(0xFF2E7D32); // Green
      case OrderStatus.readyForPickup:
        return const Color(0xFF4CAF50); // Lighter Green
      case OrderStatus.completed:
        return Colors.green[800]!;
      case OrderStatus.cancelled:
        return Colors.red[700]!;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.inProgress:
        return Icons.work;
      case OrderStatus.cutting:
        return Icons.content_cut;
      case OrderStatus.stitching:
        return Icons.design_services;
      case OrderStatus.qualityCheck:
        return Icons.fact_check;
      case OrderStatus.readyForPickup:
        return Icons.done_all;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending Confirmation';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.cutting:
        return 'Cutting in Progress';
      case OrderStatus.stitching:
        return 'Stitching in Progress';
      case OrderStatus.qualityCheck:
        return 'Quality Check in Progress';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Waiting for tailor to confirm your order';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed and work has started';
      case OrderStatus.inProgress:
        return 'Your order is currently being worked on';
      case OrderStatus.cutting:
        return 'Your item is being cut according to measurements';
      case OrderStatus.stitching:
        return 'Your item is currently being stitched';
      case OrderStatus.qualityCheck:
        return 'Your item is undergoing final quality check';
      case OrderStatus.readyForPickup:
        return 'Your order is ready for pickup';
      case OrderStatus.completed:
        return 'Your order has been completed successfully';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatEstimatedDelivery(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('MMM d, yyyy').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow, ${DateFormat('MMM d, yyyy').format(date)}';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Widget _buildTrackingTimeline(OrderModel order) {
    if (_isLoadingTracking) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Create timeline from tracking events, or use order status as fallback
    final events = _trackingEvents.isNotEmpty ? _trackingEvents : _createDefaultTimeline(order);

    if (events.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No tracking information available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(events.length, (index) {
            final event = events[index];
            final isLast = index == events.length - 1;
            final isActive = event.status == order.status;

            return _TimelineItem(
              event: event,
              isLast: isLast,
              isActive: isActive,
            );
          }),
        ),
      ),
    );
  }

  List<OrderTrackingEvent> _createDefaultTimeline(OrderModel order) {
    final List<OrderTrackingEvent> timeline = [];

    // Add order placed event
    timeline.add(OrderTrackingEvent(
      id: 'default_1',
      orderId: order.id,
      status: OrderStatus.pending,
      description: 'Order placed and pending confirmation',
      timestamp: order.orderDate,
    ));

    // Add confirmed event if exists
    if (order.confirmedDate != null) {
      timeline.add(OrderTrackingEvent(
        id: 'default_2',
        orderId: order.id,
        status: OrderStatus.confirmed,
        description: 'Order confirmed by tailor',
        timestamp: order.confirmedDate!,
      ));
    }

    // Add in progress if status is inProgress or higher
    if (order.status.index >= OrderStatus.inProgress.index) {
      timeline.add(OrderTrackingEvent(
        id: 'default_3',
        orderId: order.id,
        status: OrderStatus.inProgress,
        description: 'Order is being worked on',
        timestamp: order.confirmedDate ?? order.orderDate,
      ));
    }

    // Add cutting if status is cutting or higher
    if (order.status.index >= OrderStatus.cutting.index) {
      timeline.add(OrderTrackingEvent(
        id: 'default_cutting',
        orderId: order.id,
        status: OrderStatus.cutting,
        description: 'Item is being cut',
        timestamp: order.confirmedDate ?? order.orderDate,
      ));
    }

    // Add stitching if status is stitching or higher
    if (order.status.index >= OrderStatus.stitching.index) {
      timeline.add(OrderTrackingEvent(
        id: 'default_stitching',
        orderId: order.id,
        status: OrderStatus.stitching,
        description: 'Item is being stitched',
        timestamp: order.confirmedDate ?? order.orderDate,
      ));
    }

    // Add qualityCheck if status is qualityCheck or higher
    if (order.status.index >= OrderStatus.qualityCheck.index) {
      timeline.add(OrderTrackingEvent(
        id: 'default_quality_check',
        orderId: order.id,
        status: OrderStatus.qualityCheck,
        description: 'Performing quality check',
        timestamp: order.confirmedDate ?? order.orderDate,
      ));
    }

    // Add ready for pickup if status is readyForPickup or higher
    if (order.status.index >= OrderStatus.readyForPickup.index) {
      timeline.add(OrderTrackingEvent(
        id: 'default_4',
        orderId: order.id,
        status: OrderStatus.readyForPickup,
        description: 'Order is ready for pickup',
        timestamp: order.pickupDate ?? order.orderDate,
      ));
    }

    // Add completed if status is completed
    if (order.status == OrderStatus.completed && order.completedDate != null) {
      timeline.add(OrderTrackingEvent(
        id: 'default_5',
        orderId: order.id,
        status: OrderStatus.completed,
        description: 'Order completed and delivered',
        timestamp: order.completedDate!,
      ));
    }

    // Add cancelled if status is cancelled
    if (order.status == OrderStatus.cancelled) {
      timeline.add(OrderTrackingEvent(
        id: 'default_6',
        orderId: order.id,
        status: OrderStatus.cancelled,
        description: 'Order has been cancelled',
        timestamp: order.updatedAt,
      ));
    }

    return timeline;
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              final orderProvider = Provider.of<OrderProvider>(context, listen: false);
              final paymentService = PaymentService();
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              // Cancel the order first
              await orderProvider.updateOrderStatus(widget.order.id, OrderStatus.cancelled);

              // If already paid and online, initiate refund
              if (widget.order.paymentMethod == PaymentMethod.wallet &&
                  widget.order.paymentStatus == PaymentStatus.paid) {
                final payment = await paymentService.getPaymentByOrderId(widget.order.id);
                if (payment != null && payment.transactionId != null) {
                  await paymentService.processRefund(
                    transactionId: payment.transactionId!,
                    amount: payment.amount,
                  );
                }
              }

              if (!context.mounted) return;
              navigator.pop();
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Order cancelled successfully'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order Permanently'),
        content: const Text('Are you sure you want to permanently delete this order? This will completely erase it from the database.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              final orderProvider = Provider.of<OrderProvider>(context, listen: false);
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                await orderProvider.deleteOrder(widget.order.id);
                
                if (!context.mounted) return;
                navigator.pop(); // Close dialog
                navigator.pop(); // Go back to orders screen
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Order permanently deleted from database'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete order: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, OrderModel order) {
    final orderModel = widget.order;
    double rating = 0.0;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate & Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your experience?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        rating = (index + 1).toDouble();
                      });
                    },
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Write a review (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: rating > 0
                  ? () {
                      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                      orderProvider.addOrderReview(
                        orderModel.id,
                        rating,
                        reviewController.text,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you for your review!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final OrderTrackingEvent event;
  final bool isLast;
  final bool isActive;

  const _TimelineItem({
    required this.event,
    required this.isLast,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? _getStatusColor(event.status)
                      : Colors.grey[300],
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: isActive
                    ? Icon(
                        _getStatusIcon(event.status),
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isActive ? _getStatusColor(event.status) : Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Event details
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? _getStatusColor(event.status) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy • hh:mm a').format(event.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (event.locationName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.locationName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.purple;
      case OrderStatus.cutting:
        return Colors.blue;
      case OrderStatus.stitching:
        return Colors.indigo;
      case OrderStatus.qualityCheck:
        return Colors.teal;
      case OrderStatus.readyForPickup:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check;
      case OrderStatus.inProgress:
        return Icons.work;
      case OrderStatus.cutting:
        return Icons.content_cut;
      case OrderStatus.stitching:
        return Icons.design_services;
      case OrderStatus.qualityCheck:
        return Icons.fact_check;
      case OrderStatus.readyForPickup:
        return Icons.done;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.close;
    }
  }
}



