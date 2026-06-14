import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../models/tailor_model.dart';
import '../../utils/error_handler.dart';
import 'measurement_history_screen.dart';
import '../../services/notification_service.dart';

class RequestMeasurementScreen extends StatefulWidget {
  final TailorModel tailor;

  const RequestMeasurementScreen({
    super.key,
    required this.tailor,
  });

  @override
  State<RequestMeasurementScreen> createState() => _RequestMeasurementScreenState();
}

class _RequestMeasurementScreenState extends State<RequestMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _requestMeasurement() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final measurementProvider = Provider.of<MeasurementProvider>(context, listen: false);

      if (authProvider.user == null) {
        ErrorHandler.showErrorSnackBar(context, 'Please login to continue');
        return;
      }

      try {
        ErrorHandler.showLoadingDialog(context, 'Sending request...');

        final success = await measurementProvider.createMeasurementRequest(
          customerId: authProvider.user!.id,
          tailorId: widget.tailor.id,
          customerName: authProvider.user!.name,
          tailorName: widget.tailor.name,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          if (success) {
            // Send notification to tailor
            NotificationService().sendMeasurementNotification(
              receiverId: widget.tailor.id,
              customerName: authProvider.user!.name,
              appointmentTime: 'Not specified',
            );

            ErrorHandler.showSuccessSnackBar(context, 'Measurement request sent successfully!');
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MeasurementHistoryScreen()),
            );
          } else {
            ErrorHandler.showErrorSnackBar(
              context,
              measurementProvider.error ?? 'Failed to send request',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
          ErrorHandler.showErrorSnackBar(context, 'An error occurred. Please try again.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Measurement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tailor Info Card
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tailor.businessName ?? widget.tailor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.tailor.businessAddress ?? 'Address not provided',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Additional Notes (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Any special instructions or notes for the tailor...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The tailor will schedule an appointment and take your measurements.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Submit Button
              Consumer<MeasurementProvider>(
                builder: (context, measurementProvider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: measurementProvider.isLoading ? null : _requestMeasurement,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: measurementProvider.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Send Request',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


