import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../models/measurement_model.dart';
import '../../utils/error_handler.dart';
import '../../widgets/modern_ui_components.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AddCustomerMeasurementScreen extends StatefulWidget {
  const AddCustomerMeasurementScreen({super.key});

  @override
  State<AddCustomerMeasurementScreen> createState() =>
      _AddCustomerMeasurementScreenState();
}

class _AddCustomerMeasurementScreenState
    extends State<AddCustomerMeasurementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMeasurements() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final measurementProvider =
        Provider.of<MeasurementProvider>(context, listen: false);

    if (authProvider.user != null) {
      await measurementProvider
          .fetchAllTailorMeasurements(authProvider.user!.id);
    }
  }

  List<MeasurementModel> _getFilteredMeasurements(
      List<MeasurementModel> measurements) {
    if (_searchQuery.isEmpty) {
      return measurements;
    }
    return measurements.where((measurement) {
      return measurement.customerName.toLowerCase().contains(_searchQuery) ||
          (measurement.notes != null &&
              measurement.notes!.toLowerCase().contains(_searchQuery));
    }).toList();
  }

  Future<void> _showAddEditDialog({MeasurementModel? measurement}) async {
    await showDialog(
      context: context,
      builder: (context) => _MeasurementFormDialog(
        measurement: measurement,
        onSaved: () {
          _loadMeasurements();
        },
      ),
    );
  }

  Future<void> _deleteMeasurement(MeasurementModel measurement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Measurement'),
        content: Text(
            'Are you sure you want to delete measurements for ${measurement.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final measurementProvider =
          Provider.of<MeasurementProvider>(context, listen: false);
      ErrorHandler.showLoadingDialog(context, 'Deleting...');

      final success =
          await measurementProvider.deleteMeasurementData(measurement.id);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (success) {
          ErrorHandler.showSuccessSnackBar(
              context, 'Measurement deleted successfully!');
          _loadMeasurements();
        } else {
          ErrorHandler.showErrorSnackBar(
            context,
            measurementProvider.error ?? 'Failed to delete measurement',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Customer Measurements'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: ModernSearchBar(
              controller: _searchController,
              hintText: 'Search by customer name...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              onClear: () {
                _searchController.clear();
              },
            ),
          ),
          // Measurements List
          Expanded(
            child: Consumer<MeasurementProvider>(
              builder: (context, measurementProvider, child) {
                if (measurementProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                    ),
                  );
                }

                final measurements = _getFilteredMeasurements(
                  measurementProvider.tailorMeasurementRequests,
                );

                if (measurements.isEmpty) {
                  return ModernEmptyState(
                    icon: _searchQuery.isEmpty
                        ? Icons.people_outline_rounded
                        : Icons.search_off_rounded,
                    title: _searchQuery.isEmpty
                        ? 'No Customers Yet'
                        : 'No Customers Found',
                    subtitle: _searchQuery.isEmpty
                        ? 'Tap + to add a new customer'
                        : 'Try a different search term',
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadMeasurements,
                  color: AppTheme.primaryGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    itemCount: measurements.length,
                    itemBuilder: (context, index) {
                      final measurement = measurements[index];
                      return AnimatedFadeIn(
                        delay: index * 0.1,
                        child: _MeasurementCard(
                          measurement: measurement,
                          onEdit: () =>
                              _showAddEditDialog(measurement: measurement),
                          onDelete: () => _deleteMeasurement(measurement),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Customer'),
      ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final MeasurementModel measurement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MeasurementCard({
    required this.measurement,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showDetailsDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        measurement.customerName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          measurement.customerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Updated: ${dateFormat.format(measurement.updatedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                  ),
                ],
              ),
              if (measurement.measurements.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      measurement.measurements.entries.take(4).map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value.toStringAsFixed(1)} inches',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (measurement.measurements.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${measurement.measurements.length - 4} more',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
              if (measurement.notes != null &&
                  measurement.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.note, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          measurement.notes!,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(measurement.customerName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (measurement.measurements.isNotEmpty) ...[
                const Text(
                  'Measurements:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...measurement.measurements.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          '${entry.value.toStringAsFixed(1)} inches',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
              if (measurement.notes != null &&
                  measurement.notes!.isNotEmpty) ...[
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(measurement.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _MeasurementFormDialog extends StatefulWidget {
  final MeasurementModel? measurement;
  final VoidCallback onSaved;

  const _MeasurementFormDialog({
    this.measurement,
    required this.onSaved,
  });

  @override
  State<_MeasurementFormDialog> createState() => _MeasurementFormDialogState();
}

class _MeasurementFormDialogState extends State<_MeasurementFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
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
    if (widget.measurement != null) {
      _customerNameController.text = widget.measurement!.customerName;
      _notesController.text = widget.measurement!.notes ?? '';
      widget.measurement!.measurements.forEach((key, value) {
        if (_measurementControllers.containsKey(key)) {
          _measurementControllers[key]!.text = value.toStringAsFixed(1);
        }
      });
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _notesController.dispose();
    for (var controller in _measurementControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveMeasurement() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final measurementProvider =
          Provider.of<MeasurementProvider>(context, listen: false);

      if (authProvider.user == null || authProvider.tailor == null) {
        ErrorHandler.showErrorSnackBar(
            context, 'User not found. Please login again.');
        return;
      }

      // Collect all measurements
      final Map<String, double> measurements = {};
      _measurementControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          final value = double.tryParse(controller.text);
          if (value != null && value > 0) {
            measurements[key] = value;
          }
        }
      });

      if (measurements.isEmpty) {
        ErrorHandler.showErrorSnackBar(
            context, 'Please enter at least one measurement');
        return;
      }

      try {
        ErrorHandler.showLoadingDialog(context, 'Saving...');

        bool success;
        if (widget.measurement != null) {
          // Update existing
          success = await measurementProvider.updateMeasurementData(
            measurementId: widget.measurement!.id,
            measurements: measurements,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
        } else {
          // Create new
          success = await measurementProvider.createMeasurementWithCustomerName(
            tailorId: authProvider.user!.id,
            tailorName: authProvider.tailor!.name,
            customerName: _customerNameController.text.trim(),
            measurements: measurements,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
        }

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          Navigator.of(context).pop(); // Close form dialog

          if (success) {
            ErrorHandler.showSuccessSnackBar(
              context,
              widget.measurement != null
                  ? 'Measurement updated successfully!'
                  : 'Customer measurements saved successfully!',
            );
            widget.onSaved();
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
          ErrorHandler.showErrorSnackBar(
              context, 'An error occurred. Please try again.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.measurement != null
                          ? 'Edit Measurement'
                          : 'Add Customer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Form
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _customerNameController,
                        enabled: widget.measurement == null,
                        decoration: InputDecoration(
                          labelText: 'Customer Name *',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Measurements (inches)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._measurementControllers.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: entry.value,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: entry.key,
                              suffixText: 'inches',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final num = double.tryParse(value);
                                if (num == null || num <= 0) {
                                  return 'Invalid number';
                                }
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          prefixIcon: const Icon(Icons.note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveMeasurement,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
