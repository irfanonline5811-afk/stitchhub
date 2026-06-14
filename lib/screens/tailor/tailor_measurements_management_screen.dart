import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/measurement_model.dart';
import '../../services/measurement_service.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class TailorMeasurementsManagementScreen extends StatefulWidget {
  const TailorMeasurementsManagementScreen({super.key});

  @override
  State<TailorMeasurementsManagementScreen> createState() =>
      _TailorMeasurementsManagementScreenState();
}

class _TailorMeasurementsManagementScreenState
    extends State<TailorMeasurementsManagementScreen> {
  final MeasurementService _measurementService = MeasurementService();
  List<MeasurementModel> _measurements = [];
  bool _isLoading = true;
  String? _error;

  // Common measurement fields
  final List<String> _commonFields = [
    'Chest',
    'Waist',
    'Hip',
    'Shoulder',
    'Sleeve Length',
    'Shirt Length',
    'Pant Length',
    'Inseam',
    'Neck',
    'Bicep',
  ];

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        throw Exception('User not logged in');
      }

      final measurements =
          await _measurementService.getAllMeasurementsForTailor(
              authProvider.user!.id);
      setState(() {
        _measurements = measurements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddMeasurementDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddEditMeasurementDialog(
        isEdit: false,
        measurement: null,
        commonFields: _commonFields,
      ),
    );

    if (result != null && mounted) {
      await _createMeasurement(result);
    }
  }

  Future<void> _createMeasurement(Map<String, dynamic> data) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        throw Exception('User not logged in');
      }

      // Convert measurement values to double
      Map<String, double> measurements = {};
      for (var entry in data['measurements'].entries) {
        if (entry.value != null && entry.value.toString().isNotEmpty) {
          measurements[entry.key] = double.tryParse(entry.value.toString()) ?? 0.0;
        }
      }

      await _measurementService.createMeasurement(
        customerId: data['customerId'],
        tailorId: authProvider.user!.id,
        customerName: data['customerName'],
        tailorName: authProvider.tailor?.businessName ?? authProvider.user!.name,
        measurements: measurements,
        notes: data['notes'],
        status: MeasurementStatus.completed,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Measurement added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMeasurements();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEditMeasurementDialog(MeasurementModel measurement) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddEditMeasurementDialog(
        isEdit: true,
        measurement: measurement,
        commonFields: _commonFields,
      ),
    );

    if (result != null && mounted) {
      await _updateMeasurement(measurement.id, result);
    }
  }

  Future<void> _updateMeasurement(
      String measurementId, Map<String, dynamic> data) async {
    try {
      // Convert measurement values to double
      Map<String, double> measurements = {};
      for (var entry in data['measurements'].entries) {
        if (entry.value != null && entry.value.toString().isNotEmpty) {
          measurements[entry.key] = double.tryParse(entry.value.toString()) ?? 0.0;
        }
      }

      await _measurementService.updateMeasurement(
        measurementId: measurementId,
        measurements: measurements,
        notes: data['notes'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Measurement updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMeasurements();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteMeasurement(MeasurementModel measurement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Measurement'),
        content: Text(
            'Are you sure you want to delete measurement for ${measurement.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _measurementService.deleteMeasurement(measurement.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Measurement deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadMeasurements();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Measurements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMeasurements,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMeasurements,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _measurements.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.straighten_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No measurements found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap + to add a new measurement',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMeasurements,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _measurements.length,
                        itemBuilder: (context, index) {
                          final measurement = _measurements[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                measurement.customerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status: ${_getStatusText(measurement.status)}',
                                    style: TextStyle(
                                      color: _getStatusColor(measurement.status),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (measurement.measurements.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Measurements: ${measurement.measurements.length} fields',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    'Updated: ${DateFormat('MMM dd, yyyy').format(measurement.updatedAt)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
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
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditMeasurementDialog(measurement);
                                  } else if (value == 'delete') {
                                    _deleteMeasurement(measurement);
                                  }
                                },
                              ),
                              onTap: () {
                                _showMeasurementDetails(measurement);
                              },
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMeasurementDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Measurement'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  void _showMeasurementDetails(MeasurementModel measurement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    measurement.customerName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Status', _getStatusText(measurement.status)),
              _buildDetailRow('Created', DateFormat('MMM dd, yyyy HH:mm').format(measurement.createdAt)),
              _buildDetailRow('Updated', DateFormat('MMM dd, yyyy HH:mm').format(measurement.updatedAt)),
              if (measurement.notes != null && measurement.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(measurement.notes!),
              ],
              if (measurement.measurements.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Measurements:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...measurement.measurements.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text(
                            '${entry.value.toStringAsFixed(1)} inches',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showEditMeasurementDialog(measurement);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteMeasurement(measurement);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
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
}

class _AddEditMeasurementDialog extends StatefulWidget {
  final bool isEdit;
  final MeasurementModel? measurement;
  final List<String> commonFields;

  const _AddEditMeasurementDialog({
    required this.isEdit,
    this.measurement,
    required this.commonFields,
  });

  @override
  State<_AddEditMeasurementDialog> createState() =>
      _AddEditMeasurementDialogState();
}

class _AddEditMeasurementDialogState
    extends State<_AddEditMeasurementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _notesController = TextEditingController();
  final Map<String, TextEditingController> _measurementControllers = {};
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _customers = [];
  String? _selectedCustomerId;
  String? _selectedCustomerName;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.measurement != null) {
      _customerNameController.text = widget.measurement!.customerName;
      _customerIdController.text = widget.measurement!.customerId;
      _selectedCustomerId = widget.measurement!.customerId;
      _selectedCustomerName = widget.measurement!.customerName;
      _notesController.text = widget.measurement!.notes ?? '';

      // Initialize measurement controllers with existing values
      for (var field in widget.commonFields) {
        _measurementControllers[field] = TextEditingController(
          text: widget.measurement!.measurements[field]?.toString() ?? '',
        );
      }
    } else {
      // Initialize empty controllers for new measurement
      for (var field in widget.commonFields) {
        _measurementControllers[field] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerIdController.dispose();
    _notesController.dispose();
    for (var controller in _measurementControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _searchCustomers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _customers = [];
      });
      return;
    }

    try {
      final List<dynamic> data = await _supabase
          .from('users')
          .select('id, name, email')
          .eq('user_type', 'customer')
          .ilike('name', '%$query%')
          .limit(10);

      setState(() {
        _customers = data
            .map((e) => {
                  'id': e['id'],
                  'name': e['name'] ?? '',
                  'email': e['email'] ?? '',
                })
            .toList();
      });
    } catch (e) {
      setState(() {
        _customers = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(widget.isEdit ? 'Edit Measurement' : 'Add Measurement'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Selection (only for new measurements)
                      if (!widget.isEdit) ...[
                        TextFormField(
                          controller: _customerNameController,
                          decoration: InputDecoration(
                            labelText: 'Customer Name',
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: _customerNameController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: () {
                                      _searchCustomers(_customerNameController.text);
                                    },
                                  )
                                : null,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (value.length >= 2) {
                              _searchCustomers(value);
                            } else {
                              setState(() {
                                _customers = [];
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter customer name';
                            }
                            if (_selectedCustomerId == null) {
                              return 'Please select a customer from search results';
                            }
                            return null;
                          },
                        ),
                        if (_customers.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _customers.length,
                              itemBuilder: (context, index) {
                                final customer = _customers[index];
                                return ListTile(
                                  title: Text(customer['name']),
                                  subtitle: Text(customer['email'] ?? ''),
                                  onTap: () {
                                    setState(() {
                                      _customerNameController.text = customer['name'];
                                      _customerIdController.text = customer['id'];
                                      _selectedCustomerId = customer['id'];
                                      _selectedCustomerName = customer['name'];
                                      _customers = [];
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
                      ] else
                        TextFormField(
                          controller: _customerNameController,
                          decoration: const InputDecoration(
                            labelText: 'Customer Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                            enabled: false,
                          ),
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Measurements (in inches):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.commonFields.map((field) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              controller: _measurementControllers[field],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: field,
                                border: const OutlineInputBorder(),
                                suffixText: 'inches',
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final Map<String, dynamic> measurements = {};
                              for (var entry in _measurementControllers.entries) {
                                if (entry.value.text.isNotEmpty) {
                                  measurements[entry.key] = entry.value.text;
                                }
                              }

                              Navigator.of(context).pop({
                                'customerId': widget.isEdit
                                    ? widget.measurement!.customerId
                                    : _selectedCustomerId,
                                'customerName': widget.isEdit
                                    ? widget.measurement!.customerName
                                    : _selectedCustomerName,
                                'measurements': measurements,
                                'notes': _notesController.text.trim(),
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                          child: Text(widget.isEdit ? 'Update' : 'Add'),
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
