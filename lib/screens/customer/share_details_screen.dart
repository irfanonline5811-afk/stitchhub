import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tailor_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/customer_visit_service.dart';
import '../../services/notification_service.dart';

class ShareDetailsScreen extends StatefulWidget {
  final TailorModel tailor;

  const ShareDetailsScreen({
    super.key,
    required this.tailor,
  });

  @override
  State<ShareDetailsScreen> createState() => _ShareDetailsScreenState();
}

class _ShareDetailsScreenState extends State<ShareDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  final CustomerVisitService _visitService = CustomerVisitService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _shareDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user == null) {
          throw Exception('User not logged in');
        }

        // Create customer visit record
        await _visitService.createCustomerVisit(
          customerId: authProvider.user!.id,
          tailorId: widget.tailor.id,
          customerName: authProvider.user!.name,
          tailorName: widget.tailor.businessName ?? widget.tailor.name,
          customerPhone: _phoneController.text.trim(),
          customerEmail: _emailController.text.trim().isEmpty 
              ? null 
              : _emailController.text.trim(),
          customerAddress: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        // Send notification to tailor
        await _notificationService.sendNotification(
          userId: widget.tailor.id,
          title: 'New Customer Visit',
          body: '${authProvider.user!.name} has shared their details with you',
          data: {
            'type': 'customer_visit',
            'customerId': authProvider.user!.id,
            'tailorId': widget.tailor.id,
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Details shared successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sharing details: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tailor Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: widget.tailor.profileImageUrl != null
                            ? NetworkImage(widget.tailor.profileImageUrl!)
                            : null,
                        child: widget.tailor.profileImageUrl == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
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
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share your contact details with the tailor so they can reach out to you.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: 'Enter your phone number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  hintText: 'Enter your email',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address (Optional)',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                  hintText: 'Enter your address',
                ),
              ),
              const SizedBox(height: 16),
              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  hintText: 'Any additional information...',
                ),
              ),
              const SizedBox(height: 32),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _shareDetails,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Share Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





