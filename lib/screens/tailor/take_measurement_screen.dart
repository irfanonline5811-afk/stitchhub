import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/measurement_model.dart';
import '../../providers/measurement_provider.dart';
import '../../utils/error_handler.dart';

class TakeMeasurementScreen extends StatefulWidget {
  final MeasurementModel measurement;

  const TakeMeasurementScreen({
    super.key,
    required this.measurement,
  });

  @override
  State<TakeMeasurementScreen> createState() => _TakeMeasurementScreenState();
}

class _TakeMeasurementScreenState extends State<TakeMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  final Map<String, TextEditingController> _measurementControllers = {
    'Chest': TextEditingController(),
    'Waist': TextEditingController(),
    'Shoulder': TextEditingController(),
    'Sleeve Length': TextEditingController(),
    'Pant Length': TextEditingController(),
    'Neck': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    // Pre-fill existing measurements if any
    widget.measurement.measurements.forEach((key, value) {
      if (_measurementControllers.containsKey(key)) {
        _measurementControllers[key]!.text = value.toStringAsFixed(1);
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (var controller in _measurementControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveMeasurements() async {
    if (_formKey.currentState!.validate()) {
      final measurementProvider = Provider.of<MeasurementProvider>(context, listen: false);

      // Collect all measurements
      final Map<String, double> measurements = {};
      _measurementControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          measurements[key] = double.tryParse(controller.text) ?? 0.0;
        }
      });

      if (measurements.isEmpty) {
        ErrorHandler.showErrorSnackBar(context, 'Please enter at least one measurement');
        return;
      }

      try {
        ErrorHandler.showLoadingDialog(context, 'Saving measurements...');

        final success = await measurementProvider.takeMeasurements(
          measurementId: widget.measurement.id,
          measurements: measurements,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          if (success) {
            ErrorHandler.showSuccessSnackBar(context, 'Measurements saved successfully!');
            Navigator.of(context).pop();
          } else {
            ErrorHandler.showErrorSnackBar(
              context,
              measurementProvider.error ?? 'Failed to save measurements',
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
        title: const Text('Take Measurements'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Info Card
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
                            widget.measurement.customerName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enter measurements in inches',
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
                'Measurements (inches)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Measurement Fields
              ..._measurementControllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: entry.value,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: entry.key,
                      suffixText: 'inches',
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
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = double.tryParse(value);
                        if (num == null || num <= 0) {
                          return 'Please enter a valid number';
                        }
                      }
                      return null;
                    },
                  ),
                );
              }),
              const SizedBox(height: 20),
              // Notes Field
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
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any additional notes or comments...',
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
                      onPressed: measurementProvider.isLoading ? null : _saveMeasurements,
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
                              'Save Measurements',
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



