import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../services/manual_payment_service.dart';
import '../../models/payment_model.dart';
import '../../models/tailor_model.dart';
import '../../models/order_model.dart';
import '../../utils/error_handler.dart';
import '../../utils/app_launcher_utils.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String orderDescription;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.orderDescription,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();
  final ManualPaymentService _manualPaymentService = ManualPaymentService();
  final ImagePicker _picker = ImagePicker();
  
  // Custom Payment Inputs to match the user's payment screen mockup
  final _accountHolderNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _cnicController = TextEditingController();
  final _tidController = TextEditingController();
  
  bool _isProcessing = false;
  String? _error;
  String _selectedMethod = 'jazzcash'; // 'jazzcash', 'easypaisa'
  
  XFile? _pickedImage;
  Uint8List? _webBytes;
  TailorModel? _tailor;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  @override
  void dispose() {
    _accountHolderNameController.dispose();
    _mobileNumberController.dispose();
    _cnicController.dispose();
    _tidController.dispose();
    super.dispose();
  }

  Future<void> _loadCheckoutData() async {
    try {
      final orderData = await Supabase.instance.client
          .from('orders')
          .select()
          .eq('id', widget.orderId)
          .single();
      final order = OrderModel.fromMap(orderData);
      
      final tailorData = await Supabase.instance.client
          .from('tailors')
          .select()
          .eq('id', order.tailorId)
          .single();
      final tailor = TailorModel.fromMap(tailorData);

      if (mounted) {
        setState(() {
          _tailor = tailor;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dynamic checkout data: $e');
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  void _openWalletApp() async {
    final String appName = _selectedMethod == 'jazzcash' ? 'JazzCash' : 'EasyPaisa';
    final String package = _selectedMethod == 'jazzcash'
        ? 'com.techlogix.mobilinkcustomer'
        : 'pk.com.telenor.phoenix';
    final String playStoreUrl = _selectedMethod == 'jazzcash'
        ? 'https://play.google.com/store/apps/details?id=com.techlogix.mobilinkcustomer'
        : 'https://play.google.com/store/apps/details?id=pk.com.telenor.phoenix';
    final String appStoreUrl = _selectedMethod == 'jazzcash'
        ? 'https://apps.apple.com/pk/app/jazzcash/id1089079145'
        : 'https://apps.apple.com/pk/app/easypaisa-payments-made-easy/id1136450635';
    final String scheme = _selectedMethod == 'jazzcash' ? 'jazzcash://' : 'easypaisa://';

    try {
      final bool launched = await AppLauncherUtils.launchApp(
        packageName: package,
        iosScheme: scheme,
      );

      if (!launched) {
        throw Exception('Could not launch deep-link natively');
      }
    } catch (e) {
      debugPrint('Error launching $appName app: $e');
      if (mounted) {
        _showAppNotInstalledDialog(appName, playStoreUrl, appStoreUrl);
      }
    }
  }

  void _showAppNotInstalledDialog(String appName, String playStoreUrl, String appStoreUrl) {
    final Color themeColor = _selectedMethod == 'jazzcash' ? const Color(0xFFE53935) : const Color(0xFF4CAF50);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.app_blocking_rounded,
                    color: themeColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$appName App Not Found',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'It looks like the $appName app is not installed on your device. You can download it from the store or proceed with the payment manually.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Pay Manually',
                          style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final String url = Platform.isAndroid ? playStoreUrl : appStoreUrl;
                          final Uri storeUri = Uri.parse(url);
                          if (await canLaunchUrl(storeUri)) {
                            await launchUrl(storeUri, mode: LaunchMode.externalApplication);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Download App',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
            _error = null;
          });
        } else {
          setState(() {
            _pickedImage = image;
            _error = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking screenshot: $e');
      setState(() {
        _error = 'Could not select image. Please try again.';
      });
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickedImage == null) {
      setState(() {
        _error = 'Please upload a screenshot of your payment receipt.';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        throw Exception('User not logged in');
      }

      final String inputTid = _tidController.text.trim();
      final String methodLabel = _selectedMethod == 'jazzcash' ? 'JazzCash' : 'EasyPaisa';

      // 1. Upload actual receipt image to Supabase Storage
      String? screenshotUrl;
      if (kIsWeb) {
        screenshotUrl = await _manualPaymentService.uploadPaymentScreenshot(
          orderId: widget.orderId,
          imageFile: null,
          imageBytes: _webBytes,
          fileExtension: _pickedImage!.name.split('.').last,
        );
      } else {
        screenshotUrl = await _manualPaymentService.uploadPaymentScreenshot(
          orderId: widget.orderId,
          imageFile: File(_pickedImage!.path),
          imageBytes: null,
          fileExtension: _pickedImage!.path.split('.').last,
        );
      }

      if (screenshotUrl == null) {
        throw Exception('Failed to upload screenshot to server.');
      }

      // 2. Save payment record inside main payments table
      await _paymentService.savePayment(
        orderId: widget.orderId,
        customerId: authProvider.user!.id,
        amount: widget.amount,
        transactionId: inputTid,
        paymentMethod: _selectedMethod,
        status: PaymentTransactionStatus.pending,
        metadata: {
          'orderDescription': widget.orderDescription,
          'method': methodLabel,
          'receiptImage': screenshotUrl,
          'accountHolderName': _accountHolderNameController.text.trim(),
          'mobileNumber': _mobileNumberController.text.trim(),
          'cnicLast6': _cnicController.text.trim(),
        },
      );

      // 3. Save inside manual_payments table for tailor verification flow
      final String formattedPhone = "${_mobileNumberController.text.trim()} (CNIC: ${_cnicController.text.trim()})";

      await _manualPaymentService.submitManualPayment(
        orderId: widget.orderId,
        customerName: _accountHolderNameController.text.trim(),
        customerPhone: formattedPhone,
        amount: widget.amount,
        paymentMethod: _selectedMethod,
        transactionId: inputTid,
        screenshotUrl: screenshotUrl,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              orderId: widget.orderId,
              transactionId: inputTid,
              amount: widget.amount,
              paymentMethod: methodLabel,
              date: DateTime.now(),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '');
        _isProcessing = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, _error ?? 'Payment failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Order ID:'),
                          Text(
                            widget.orderId.length > 8 
                                ? widget.orderId.substring(0, 8) 
                                : widget.orderId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Description:'),
                          Expanded(
                            child: Text(
                              widget.orderDescription,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rs. ${widget.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Payment Method Selection
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMethodOption('jazzcash', Icons.wallet, 'JazzCash'),
                    const SizedBox(width: 8),
                    _buildMethodOption('easypaisa', Icons.account_balance_wallet, 'EasyPaisa'),
                  ],
                ),
                const SizedBox(height: 24),

                // Wallet Instructions
                _buildWalletInstructions(),
                
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Payment Button
                ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Submit Payment (Rs. ${widget.amount.toStringAsFixed(0)})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Security Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your payment is secure and encrypted',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
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
      );
    }

    Widget _buildMethodOption(String method, IconData icon, String label) {
      bool isSelected = _selectedMethod == method;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedMethod = method),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    InputDecoration _buildInputDecoration({
      required String labelText,
      required IconData prefixIcon,
      required Color primaryColor,
    }) {
      return InputDecoration(
        labelText: labelText,
        prefixIcon: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(prefixIcon, color: Colors.grey[600], size: 20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      );
    }

    Widget _buildWalletInstructions() {
      final String walletName = _selectedMethod == 'jazzcash' ? 'JazzCash' : 'EasyPaisa';
      final Color walletColor = _selectedMethod == 'jazzcash' ? const Color(0xFFE53935) : const Color(0xFF4CAF50);
      const Color themeColor = Color(0xFF2E7D32); // Forest Green primary theme
      
      // Dynamic tailor lookup credentials with defaults
      String accountNumber = '0300-1234567';
      String accountTitle = 'StitchHub Tailors PVT';

      if (_tailor != null) {
        if (_selectedMethod == 'jazzcash') {
          if (_tailor!.jazzcashNumber != null && _tailor!.jazzcashNumber!.isNotEmpty) {
            accountNumber = _tailor!.jazzcashNumber!;
            accountTitle = _tailor!.jazzcashTitle ?? _tailor!.businessName ?? _tailor!.name;
          }
        } else {
          if (_tailor!.easypaisaNumber != null && _tailor!.easypaisaNumber!.isNotEmpty) {
            accountNumber = _tailor!.easypaisaNumber!;
            accountTitle = _tailor!.easypaisaTitle ?? _tailor!.businessName ?? _tailor!.name;
          }
        }
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: walletColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.info_outline, color: walletColor),
                ),
                const SizedBox(width: 12),
                Text(
                  'How to pay via $walletName',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Step 1: Account Details Form
            _buildStep('1', 'Enter your account details below.'),
            const SizedBox(height: 12),
            
            // Account Holder Name TextFormField
            TextFormField(
              controller: _accountHolderNameController,
              decoration: _buildInputDecoration(
                labelText: 'Account Holder Name',
                prefixIcon: Icons.person_outline,
                primaryColor: themeColor,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter account holder name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // Mobile Number TextFormField
            TextFormField(
              controller: _mobileNumberController,
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icons.phone_android_outlined,
                primaryColor: themeColor,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // CNIC Number TextFormField
            TextFormField(
              controller: _cnicController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: _buildInputDecoration(
                labelText: 'CNIC Number (Last 6 digits)',
                prefixIcon: Icons.credit_card_outlined,
                primaryColor: themeColor,
              ).copyWith(counterText: ''),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter last 6 digits of CNIC';
                }
                if (value.trim().length != 6) {
                  return 'Must be exactly 6 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // Transaction ID TextFormField
            TextFormField(
              controller: _tidController,
              decoration: _buildInputDecoration(
                labelText: 'Transaction ID (TID)',
                prefixIcon: Icons.tag,
                primaryColor: themeColor,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter Transaction ID';
                }
                if (value.trim().length < 6) {
                  return 'Enter a valid Transaction ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Open Wallet App Button (Big RED/GREEN button)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openWalletApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: walletColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 4,
                  shadowColor: walletColor.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Open $walletName App',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Step 2: Transfer Details instructions
            _buildStep('2', 'Transfer Rs. ${widget.amount.toStringAsFixed(0)} to the following details in your $walletName app:'),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Account Title:',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        accountTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Account Number:',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Row(
                        children: [
                          Text(
                            accountNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.copy, size: 16, color: Color(0xFF2E7D32)),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: accountNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Account number copied to clipboard!'),
                                  backgroundColor: Color(0xFF2E7D32),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Upload Receipt',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.none),
                ),
                child: Center(
                  child: _pickedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.grey[600], size: 40),
                            const SizedBox(height: 8),
                            Text('Click to upload screenshot', style: TextStyle(color: Colors.grey[600])),
                          ],
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb
                                  ? Image.memory(
                                      _webBytes!,
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_pickedImage!.path),
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                  onPressed: () => setState(() => _pickedImage = null),
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
      );
    }

    Widget _buildStep(String number, String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: const Color(0xFF2E7D32),
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          ],
        ),
      );
    }
}
