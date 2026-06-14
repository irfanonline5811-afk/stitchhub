import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import 'package:intl/intl.dart';

class OrderTimelineScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTimelineScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order Summary Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Status',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStatusText(order.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.inventory_2, color: Colors.white, size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderInfo('Order ID', '#${order.id.substring(0, 8)}'),
                      _buildHeaderInfo('Price', 'Rs. ${order.price.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildTimelineStep(
                    'Order Placed',
                    'Your order has been sent to the tailor.',
                    order.createdAt,
                    order.status.index >= OrderStatus.pending.index,
                    isFirst: true,
                  ),
                  _buildTimelineStep(
                    'Confirmed',
                    'Tailor has accepted your order.',
                    order.confirmedDate ?? order.createdAt,
                    order.status.index >= OrderStatus.confirmed.index,
                  ),
                  _buildTimelineStep(
                    'Cutting',
                    'Fabric is being cut as per measurements.',
                    null,
                    order.status.index >= OrderStatus.cutting.index,
                  ),
                  _buildTimelineStep(
                    'Stitching',
                    'Tailor is stitching your suit.',
                    null,
                    order.status.index >= OrderStatus.stitching.index,
                  ),
                  _buildTimelineStep(
                    'Ready',
                    'Your suit is ready for pickup/delivery.',
                    order.pickupDate,
                    order.status.index >= OrderStatus.readyForPickup.index,
                  ),
                  _buildTimelineStep(
                    'Completed',
                    'Order delivered successfully.',
                    order.completedDate,
                    order.status.index >= OrderStatus.completed.index,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, DateTime? date, bool isCompleted, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line and Dot
        Column(
          children: [
            Container(
              width: 2,
              height: 20,
              color: isFirst ? Colors.transparent : (isCompleted ? const Color(0xFF2E7D32) : Colors.grey[300]),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF2E7D32) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey[300]!,
                  width: 3,
                ),
                boxShadow: isCompleted ? [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ] : null,
              ),
              child: isCompleted ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
            ),
            Container(
              width: 2,
              height: 60,
              color: isLast ? Colors.transparent : (isCompleted ? const Color(0xFF2E7D32) : Colors.grey[300]),
            ),
          ],
        ),
        const SizedBox(width: 20),
        // Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                  if (date != null && isCompleted)
                    Text(
                      DateFormat('hh:mm a').format(date),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isCompleted ? Colors.grey[600] : Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.inProgress: return 'In Progress';
      case OrderStatus.cutting: return 'Cutting';
      case OrderStatus.stitching: return 'Stitching';
      case OrderStatus.qualityCheck: return 'Quality Check';
      case OrderStatus.readyForPickup: return 'Ready';
      case OrderStatus.completed: return 'Completed';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
}

