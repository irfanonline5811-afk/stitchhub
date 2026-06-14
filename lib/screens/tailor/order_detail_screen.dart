import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../models/order_tracking_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_tracking_service.dart';
import '../../services/measurement_service.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import '../../utils/url_utils.dart';
import '../../models/user_model.dart';

class TailorOrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const TailorOrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<TailorOrderDetailScreen> createState() => _TailorOrderDetailScreenState();
}

class _TailorOrderDetailScreenState extends State<TailorOrderDetailScreen> {
  final OrderTrackingService _trackingService = OrderTrackingService();
  final AuthService _authService = AuthService();
  List<OrderTrackingEvent> _trackingEvents = [];
  bool _isLoadingTracking = true;
  UserModel? _customerUser; // To get the phone number

  @override
  void initState() {
    super.initState();
    _loadTrackingHistory();
    _loadCustomerInfo();
  }

  Future<void> _loadCustomerInfo() async {
    final user = await _authService.getUserProfile(widget.order.customerId);
    if (mounted) {
      setState(() {
        _customerUser = user;
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
          if (order.status == OrderStatus.pending)
            PopupMenuButton<String>(
              onSelected: (action) {
                switch (action) {
                  case 'accept':
                    _showConfirmDialog(context, order);
                    break;
                  case 'reject':
                    _showRejectDialog(context, order);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'accept',
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Accept Order'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: Row(
                    children: [
                      Icon(Icons.close, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Reject Order'),
                    ],
                  ),
                ),
              ],
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
            // Customer Information
            const Text(
              'Customer Information',
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
                            order.customerName[0].toUpperCase(),
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
                                order.customerName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                order.customerAddress ?? 'Address not provided',
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
                              onPressed: _customerUser != null ? () {
                                UrlUtils.makeCall(_customerUser!.phone);
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
                              onPressed: _customerUser != null ? () {
                                UrlUtils.openWhatsApp(
                                  _customerUser!.phone, 
                                  "Hello ${order.customerName}, I'm working on your Order #${order.id.substring(0,8)}."
                                );
                              } : null,
                              icon: const Icon(Icons.message, color: Colors.green),
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _requestMeasurement(context, order);
                        },
                        icon: const Icon(Icons.straighten),
                        label: const Text('Request Measurements'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                        ),
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
            // Action Buttons
            if (order.status != OrderStatus.completed && order.status != OrderStatus.cancelled) ...[
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildActionButtons(context, order),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderModel order) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showConfirmDialog(context, widget.order),
                icon: const Icon(Icons.check),
                label: const Text('Accept Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showRejectDialog(context, widget.order),
                icon: const Icon(Icons.close),
                label: const Text('Reject Order'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        );
      case OrderStatus.confirmed:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _updateOrderStatusWithTracking(
              widget.order,
              OrderStatus.cutting,
              'Tailor has started cutting the fabric',
            ),
            icon: const Icon(Icons.content_cut),
            label: const Text('Start Cutting'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        );
      case OrderStatus.cutting:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _updateOrderStatusWithTracking(
              widget.order,
              OrderStatus.stitching,
              'Tailor is now stitching the suit',
            ),
            icon: const Icon(Icons.gesture),
            label: const Text('Start Stitching'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          ),
        );
      case OrderStatus.stitching:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _updateOrderStatusWithTracking(
              widget.order,
              OrderStatus.qualityCheck,
              'Stitching complete, now performing quality check',
            ),
            icon: const Icon(Icons.fact_check),
            label: const Text('Start Quality Check'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          ),
        );
      case OrderStatus.qualityCheck:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _updateOrderStatusWithTracking(
              widget.order,
              OrderStatus.readyForPickup,
              'Quality check passed, ready for pickup',
            ),
            icon: const Icon(Icons.done_all),
            label: const Text('Mark as Ready'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        );
      case OrderStatus.readyForPickup:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _updateOrderStatusWithTracking(
              widget.order,
              OrderStatus.completed,
              'Order completed and delivered',
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark as Completed'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
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
        return Icons.gesture;
      case OrderStatus.qualityCheck:
        return Icons.fact_check;
      case OrderStatus.readyForPickup:
        return Icons.done_all;
      case OrderStatus.completed:
        return Icons.verified;
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
        return 'Cutting Fabric';
      case OrderStatus.stitching:
        return 'Stitching Suit';
      case OrderStatus.qualityCheck:
        return 'Quality Check';
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
        return 'Waiting for your confirmation';
      case OrderStatus.confirmed:
        return 'Order confirmed, ready to start work';
      case OrderStatus.inProgress:
        return 'Order is in progress';
      case OrderStatus.cutting:
        return 'You are currently cutting the fabric';
      case OrderStatus.stitching:
        return 'You are currently stitching the suit';
      case OrderStatus.qualityCheck:
        return 'Checking the quality of the suit';
      case OrderStatus.readyForPickup:
        return 'Order is ready for customer pickup';
      case OrderStatus.completed:
        return 'Order has been completed successfully';
      case OrderStatus.cancelled:
        return 'Order has been cancelled';
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

    // Add cutting if status is cutting or higher
    if (order.status.index >= OrderStatus.cutting.index) {
      timeline.add(OrderTrackingEvent(
        id: 'default_3',
        orderId: order.id,
        status: OrderStatus.cutting,
        description: 'Tailor has started cutting the fabric',
        timestamp: order.updatedAt, // Fallback to last update
      ));
    }

    // Add stitching if status is stitching or higher
    if (order.status.index >= OrderStatus.stitching.index) {
      timeline.add(OrderTrackingEvent(
        id: 'default_4',
        orderId: order.id,
        status: OrderStatus.stitching,
        description: 'Tailor is now stitching the suit',
        timestamp: order.updatedAt,
      ));
    }

    // Add ready for pickup if status is readyForPickup or higher
    if (order.status.index >= OrderStatus.readyForPickup.index) {
      timeline.add(OrderTrackingEvent(
        id: 'default_5',
        orderId: order.id,
        status: OrderStatus.readyForPickup,
        description: 'Order is ready for pickup',
        timestamp: order.pickupDate ?? order.updatedAt,
      ));
    }

    // Add completed if status is completed
    if (order.status == OrderStatus.completed && order.completedDate != null) {
      timeline.add(OrderTrackingEvent(
        id: 'default_6',
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

  Future<void> _updateOrderStatusWithTracking(OrderModel order, OrderStatus newStatus, String description) async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      
      // Update order status
      await orderProvider.updateOrderStatus(order.id, newStatus);
      
      // Create tracking event
      await _trackingService.addTrackingEvent(
        orderId: order.id,
        status: newStatus,
        description: description,
      );
      
      // Reload tracking history
      await _loadTrackingHistory();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated: ${_getStatusText(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showConfirmDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text('Are you sure you want to accept this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _updateOrderStatusWithTracking(
                order,
                OrderStatus.confirmed,
                'Order confirmed by tailor',
              );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, OrderModel order) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejecting this order:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Reason for rejection...',
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
            onPressed: () async {
              final reason = reasonController.text;
              Navigator.of(context).pop();
              await _updateOrderStatusWithTracking(
                order,
                OrderStatus.cancelled,
                'Order rejected by tailor: ${reason.isEmpty ? "No reason provided" : reason}',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestMeasurement(BuildContext context, OrderModel order) async {
    final TextEditingController notesController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Measurements'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Send a measurement request to the customer?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Additional notes (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Request'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!context.mounted) return;
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final measurementService = MeasurementService();
        final notificationService = NotificationService();

        if (authProvider.user == null || authProvider.tailor == null) {
          throw Exception('User not logged in');
        }

        // Create measurement request
        final measurement = await measurementService.requestMeasurementFromCustomer(
          tailorId: authProvider.user!.id,
          customerId: order.customerId,
          tailorName: authProvider.tailor!.businessName ?? authProvider.user!.name,
          customerName: order.customerName,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        );

        // Send notification to customer
        await notificationService.sendMeasurementRequestNotification(
          customerId: order.customerId,
          tailorName: authProvider.tailor!.businessName ?? authProvider.user!.name,
          measurementId: measurement?.id,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Measurement request sent to customer!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error requesting measurement: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
        return Colors.indigo;
      case OrderStatus.stitching:
        return Colors.purple;
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
        return Icons.gesture;
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



