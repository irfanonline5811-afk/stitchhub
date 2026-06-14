import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../models/measurement_model.dart';
import 'take_measurement_screen.dart';
import 'schedule_measurement_screen.dart';

class TailorMeasurementRequestsScreen extends StatefulWidget {
  const TailorMeasurementRequestsScreen({super.key});

  @override
  State<TailorMeasurementRequestsScreen> createState() => _TailorMeasurementRequestsScreenState();
}

class _TailorMeasurementRequestsScreenState extends State<TailorMeasurementRequestsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final measurementProvider = Provider.of<MeasurementProvider>(context, listen: false);

    debugPrint('TailorMeasurementRequestsScreen: _loadRequests called. user: ${authProvider.user?.id}');

    if (authProvider.user != null) {
      await measurementProvider.fetchTailorMeasurementRequests(authProvider.user!.id);
    } else {
      // If user is null, wait a bit and try again once
      debugPrint('TailorMeasurementRequestsScreen: User is null, retrying in 2 seconds...');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted && authProvider.user != null) {
        await measurementProvider.fetchTailorMeasurementRequests(authProvider.user!.id);
      }
    }
  }

  Color _getStatusColor(MeasurementStatus status) {
    switch (status) {
      case MeasurementStatus.pending:
        return Colors.orange;
      case MeasurementStatus.scheduled:
        return Colors.blue;
      case MeasurementStatus.completed:
        return Colors.green;
      case MeasurementStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(MeasurementStatus status) {
    switch (status) {
      case MeasurementStatus.pending:
        return 'Pending';
      case MeasurementStatus.scheduled:
        return 'Scheduled';
      case MeasurementStatus.completed:
        return 'Completed';
      case MeasurementStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurement Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: Consumer<MeasurementProvider>(
        builder: (context, measurementProvider, child) {
          if (measurementProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (measurementProvider.tailorMeasurementRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.straighten_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Measurement Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Measurement requests from customers will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadRequests,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: measurementProvider.tailorMeasurementRequests.length,
              itemBuilder: (context, index) {
                final measurement = measurementProvider.tailorMeasurementRequests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        if (measurement.status == MeasurementStatus.pending) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ScheduleMeasurementScreen(
                                measurement: measurement,
                              ),
                            ),
                          );
                        } else if (measurement.status == MeasurementStatus.scheduled) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TakeMeasurementScreen(
                                measurement: measurement,
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.straighten,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    measurement.customerName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Requested: ${_formatDate(measurement.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(measurement.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getStatusText(measurement.status),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(measurement.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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


