import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/manual_payment_service.dart';
import 'manual_payment_pending_screen.dart';

class ManualUploadScreenshotScreen extends StatefulWidget {
  final OrderModel order;
  final String paymentMethod;

  const ManualUploadScreenshotScreen({
    super.key,
    required this.order,
    required this.paymentMethod,
  });

  @override
  State<ManualUploadScreenshotScreen> createState() => _ManualUploadScreenshotScreenState();
}

class _ManualUploadScreenshotScreenState extends State<ManualUploadScreenshotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tidController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ManualPaymentService _paymentService = ManualPaymentService();

  XFile? _pickedImage;
  Uint8List? _webBytes;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void dispose() {
    _tidController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _pickedImage = image;
            _webBytes = bytes;
            _uploadError = null;
          });
        } else {
          setState(() {
            _pickedImage = image;
            _uploadError = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking screenshot: $e');
      setState(() {
        _uploadError = 'Could not select image. Please try again.';
      });
    }
  }

  void _submitProof() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickedImage == null) {
      setState(() {
        _uploadError = 'Please upload a screenshot of your payment receipt.';
      });
      return;
    }

    // Fetch customer phone number dynamically from active AuthProvider session BEFORE async gaps
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String customerPhone = (authProvider.user?.phone != null && authProvider.user!.phone.isNotEmpty)
        ? authProvider.user!.phone
        : '+923000000000';

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      String? screenshotUrl;
      
      // 1. Upload to Supabase Storage bucket 'payment-proofs'
      if (kIsWeb) {
        screenshotUrl = await _paymentService.uploadPaymentScreenshot(
          orderId: widget.order.id,
          imageFile: null,
          imageBytes: _webBytes,
          fileExtension: _pickedImage!.name.split('.').last,
        );
      } else {
        screenshotUrl = await _paymentService.uploadPaymentScreenshot(
          orderId: widget.order.id,
          imageFile: File(_pickedImage!.path),
          imageBytes: null,
          fileExtension: _pickedImage!.path.split('.').last,
        );
      }

      if (screenshotUrl == null) {
        throw Exception('Screenshot upload failed (received null URL)');
      }

      // 2. Submit payment details in database
      final payment = await _paymentService.submitManualPayment(
        orderId: widget.order.id,
        customerName: widget.order.customerName,
        customerPhone: customerPhone,
        amount: widget.order.price,
        paymentMethod: widget.paymentMethod,
        transactionId: _tidController.text.trim(),
        screenshotUrl: screenshotUrl,
      );

      if (mounted) {
        // Navigate to Pending screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => ManualPaymentPendingScreen(
              payment: payment,
              order: widget.order,
            ),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      debugPrint('Error submitting payment proof: $e');
      setState(() {
        _uploadError = e.toString().replaceAll('Exception:', '');
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Submit Payment Proof'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Receipt selector card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing20),
                  child: Column(
                    children: [
                      const Text(
                        'Upload Payment Screenshot',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      const Text(
                        'Upload a screenshot of the confirmation page or transaction receipt message.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.gray600, fontSize: 13),
                      ),
                      const SizedBox(height: AppTheme.spacing20),
                      
                      // Screenshot Preview Box
                      InkWell(
                        onTap: _isUploading ? null : _pickImage,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.gray50,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(
                              color: _pickedImage != null ? AppTheme.primaryGreen : AppTheme.gray300,
                              style: _pickedImage != null ? BorderStyle.solid : BorderStyle.none,
                              width: 1.5,
                            ),
                          ),
                          child: _pickedImage == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, color: AppTheme.gray600, size: 48),
                                    SizedBox(height: AppTheme.spacing8),
                                    Text('Tap to choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium - 1),
                                  child: kIsWeb
                                      ? Image.memory(
                                          _webBytes!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : Image.file(
                                          File(_pickedImage!.path),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                  ),
                        ),
                      ),
                      if (_pickedImage != null && !_isUploading) ...[
                        const SizedBox(height: AppTheme.spacing8),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryGreen),
                          label: const Text('Change Screenshot', style: TextStyle(color: AppTheme.primaryGreen)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing20),

              // Transaction TID Inputs Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction ID (TID)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                      TextFormField(
                        controller: _tidController,
                        enabled: !_isUploading,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Enter 11 or 12 digit TID',
                          prefixIcon: const Icon(Icons.tag_rounded),
                          filled: true,
                          fillColor: AppTheme.gray50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            borderSide: const BorderSide(color: AppTheme.gray200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the transaction ID';
                          }
                          if (value.trim().length < 8) {
                            return 'Invalid transaction ID format (Too short)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Upload & Submit Error
              if (_uploadError != null) ...[
                const SizedBox(height: AppTheme.spacing16),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppTheme.error),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          _uploadError!,
                          style: const TextStyle(color: AppTheme.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppTheme.spacing32),

              // Submit Button
              ElevatedButton(
                onPressed: _isUploading ? null : _submitProof,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: _isUploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                            ),
                          ),
                          SizedBox(width: AppTheme.spacing12),
                          Text('Uploading Payment Proof...'),
                        ],
                      )
                    : const Text(
                        'Submit Payment Proof',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
