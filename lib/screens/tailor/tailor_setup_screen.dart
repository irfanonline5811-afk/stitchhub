import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../services/tailor_service.dart';
import '../../services/auth_service.dart';
import '../../models/tailor_model.dart';
import '../../widgets/city_selection_dialog.dart';
import 'tailor_home_screen.dart';

class TailorSetupScreen extends StatefulWidget {
  const TailorSetupScreen({super.key});

  @override
  State<TailorSetupScreen> createState() => _TailorSetupScreenState();
}

class _TailorSetupScreenState extends State<TailorSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _expertiseController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _featuredReviewController = TextEditingController();
  final _jazzcashNumberController = TextEditingController();
  final _jazzcashTitleController = TextEditingController();
  final _easypaisaNumberController = TextEditingController();
  final _easypaisaTitleController = TextEditingController();
  double _initialRating = 5.0; // Default to 5 stars
  final FocusNode _addressFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  final List<String> _selectedServices = [];
  final Map<String, double> _pricing = {};
  final List<String> _availableDays = [];
  String _startTime = '09:00';
  String _endTime = '18:00';
  List<File> _workSamples = [];
  File? _profileImage;

  final List<String> _serviceOptions = [
    'Shirt',
    'Pants',
    'Dress',
    'Suit',
    'Kurta',
    'Saree',
    'Coat',
    'Skirt',
  ];

  final List<String> _dayOptions = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _expertiseController.dispose();
    _basePriceController.dispose();
    _descriptionController.dispose();
    _featuredReviewController.dispose();
    _jazzcashNumberController.dispose();
    _jazzcashTitleController.dispose();
    _easypaisaNumberController.dispose();
    _easypaisaTitleController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  final List<String> _pkCities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Peshawar',
    'Quetta',
    'Sialkot',
    'Gujranwala',
    'Hyderabad',
    'Abbottabad',
    'Bahawalpur',
    'Sargodha',
    'Sukkur',
    'Larkana',
    'Sheikhupura',
    'Rahim Yar Khan',
    'Jhang',
    'Dera Ghazi Khan',
    'Gujrat',
    'Sahiwal',
    'Wah Cantonment',
    'Mardan',
    'Kasur',
    'Okara',
    'Mingora',
    'Nawabshah',
    'Chiniot',
    'Kotri',
    'Kamoke',
    'Hafizabad',
    'Sadiqabad',
    'Mirpur Khas',
    'Burewala',
    'Kohat',
    'Khanewal',
    'Dera Ismail Khan',
    'Turbat',
    'Muzaffargarh',
    'Mandi Bahauddin',
    'Shikarpur',
    'Jacobabad',
    'Jhelum',
    'Khanpur',
    'Khairpur',
    'Khuzdar',
    'Pakpattan',
    'Hub',
    'Daska',
    'Gojra',
    'Dadu',
    'Muridke',
    'Bahawalnagar',
    'Samundri',
    'Tando Allahyar',
    'Tando Adam',
    'Jaranwala',
    'Chishtian',
    'Muzaffarabad',
    'Attock',
    'Vehari',
    'Kot Abdul Malik',
    'Ferozwala',
    'Chakwal',
    'Kamalia',
    'Umerkot',
    'Ahmedpur East',
    'Kot Addu',
    'Wazirabad',
    'Mansehra',
    'Layyah',
    'Swabi',
    'Chaman',
    'Taxila',
    'Nowshera',
    'Khushab',
    'Shahdadkot',
    'Mianwali',
    'Kabal',
    'Lodhran',
    'Charsadda',
  ];

  Future<void> _initializeLocation() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    await locationProvider.getCurrentLocation();
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickWorkSamples() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (!mounted) return;
      setState(() {
        _workSamples = images.map((image) => File(image.path)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeSetup() async {
    if (_formKey.currentState!.validate() && _selectedServices.isNotEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      final tailorService = TailorService();

      if (authProvider.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if location is available, if not try to get it
      if (locationProvider.currentPosition == null) {
        // Show loading dialog while fetching location
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                  SizedBox(height: 8),
                  Text(
                    'This may take a few seconds',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );

        try {
          // Try to get location
          await locationProvider.getCurrentLocation();

          if (!mounted) return;
          Navigator.of(context).pop(); // Close loading dialog

          // Check again if location was obtained
          if (locationProvider.currentPosition == null) {
            String errorMessage =
                locationProvider.error ?? 'Please enable location services';
            if (!mounted) return;
            // Show dialog with retry option
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Location Error'),
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Retry getting location
                      _completeSetup();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
            return;
          }
        } catch (e) {
          if (!mounted) return;
          Navigator.of(context).pop(); // Close loading dialog
          String errorMsg = 'Error getting location';
          if (e.toString().contains('TimeoutException')) {
            errorMsg =
                'Location request timed out. Please check your GPS signal and try again.';
          } else {
            errorMsg = 'Error: ${e.toString()}';
          }
          // Show dialog with retry option
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Error'),
              content: Text(errorMsg),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Retry getting location
                    _completeSetup();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
          return;
        }
      }

      // Show loading

      try {
        // Upload profile image if selected
        String? profileImageUrl;
        if (_profileImage != null) {
          final authService = AuthService();
          profileImageUrl = await authService.uploadProfileImage(
            _profileImage!,
            authProvider.user!.id,
          );
          // Update user profile image
          if (profileImageUrl != null) {
            await authProvider.updateProfile(profileImageUrl: profileImageUrl);
          }
        } else {
          // Use existing profile image if available
          profileImageUrl = authProvider.user?.profileImageUrl;
        }

        // Upload work samples
        List<String> workSampleUrls = [];
        for (final file in _workSamples) {
          final url = await tailorService.uploadWorkSample(
            file,
            authProvider.user!.id,
          );
          if (url != null) {
            workSampleUrls.add(url);
          }
        }

        // Check if tailor exists, if not create a new one from user data
        TailorModel updatedTailor;
        if (authProvider.tailor != null) {
          // Update existing tailor profile
          updatedTailor = authProvider.tailor!.copyWithTailor(
            businessName: _businessNameController.text.trim(),
            businessAddress: _businessAddressController.text.trim(),
            specialties: _expertiseController.text.trim().isNotEmpty
                ? _expertiseController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList()
                : [],
            basePrice: _basePriceController.text.trim(),
            latitude: locationProvider.currentPosition!.latitude,
            longitude: locationProvider.currentPosition!.longitude,
            services: _selectedServices,
            pricing: _pricing,
            availableDays: _availableDays,
            startTime: _startTime,
            endTime: _endTime,
            workSamples: workSampleUrls,
            profileImageUrl: profileImageUrl,
            rating: _initialRating,
            totalReviews: _featuredReviewController.text.isNotEmpty ? 1 : 0,
            description: _descriptionController.text.trim() + (_featuredReviewController.text.isNotEmpty ? "\n\n★ Featured Review: ${_featuredReviewController.text.trim()}" : ""),
            updatedAt: DateTime.now(),
            jazzcashNumber: _jazzcashNumberController.text.trim(),
            jazzcashTitle: _jazzcashTitleController.text.trim(),
            easypaisaNumber: _easypaisaNumberController.text.trim(),
            easypaisaTitle: _easypaisaTitleController.text.trim(),
          );
        } else {
          // Create new tailor profile from user data
          final user = authProvider.user!;
          updatedTailor = TailorModel(
            id: user.id,
            email: user.email,
            name: user.name,
            phone: user.phone,
            profileImageUrl: profileImageUrl ?? user.profileImageUrl,
            createdAt: user.createdAt,
            updatedAt: DateTime.now(),
            businessName: _businessNameController.text.trim(),
            businessAddress: _businessAddressController.text.trim(),
            specialties: _expertiseController.text.trim().isNotEmpty
                ? _expertiseController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList()
                : [],
            basePrice: _basePriceController.text.trim(),
            description: _descriptionController.text.trim() + (_featuredReviewController.text.isNotEmpty ? "\n\n★ Featured Review: ${_featuredReviewController.text.trim()}" : ""),
            latitude: locationProvider.currentPosition!.latitude,
            longitude: locationProvider.currentPosition!.longitude,
            services: _selectedServices,
            pricing: _pricing,
            availableDays: _availableDays,
            startTime: _startTime,
            endTime: _endTime,
            workSamples: workSampleUrls,
            isAvailable: true,
            rating: _initialRating,
            totalReviews: _featuredReviewController.text.isNotEmpty ? 1 : 0,
            jazzcashNumber: _jazzcashNumberController.text.trim(),
            jazzcashTitle: _jazzcashTitleController.text.trim(),
            easypaisaNumber: _easypaisaNumberController.text.trim(),
            easypaisaTitle: _easypaisaTitleController.text.trim(),
          );
        }

        await authProvider.updateTailorProfile(updatedTailor);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TailorHomeScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Profile Setup Successful!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error completing setup: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Let\'s set up your tailor profile to start receiving orders!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  // Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (authProvider.user?.profileImageUrl != null
                                  ? NetworkImage(
                                      authProvider.user!.profileImageUrl!,
                                    )
                                  : null) as ImageProvider?,
                          child: _profileImage == null &&
                                  authProvider.user?.profileImageUrl == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF2E7D32),
                            child: IconButton(
                              onPressed: _pickProfileImage,
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Tap to upload profile picture',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Business Information
                  const Text(
                    'Business Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(
                      labelText: 'Business Name',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your business name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _businessAddressController,
                    readOnly: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => CitySelectionDialog(
                          cities: _pkCities,
                          onCitySelected: (selectedCity) {
                            setState(() {
                              _businessAddressController.text = selectedCity;
                            });
                          },
                        ),
                      );
                    },
                    decoration: const InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      hintText: 'Tap to select city',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your city';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _expertiseController,
                    decoration: const InputDecoration(
                      labelText: 'Expertise (e.g., Suits, Dresses)',
                      prefixIcon: Icon(Icons.content_cut),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _basePriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Base Pricing (Starting from)',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PKR',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                      hintText: 'Tell customers about your services...',
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Payment Wallets Setup Section
                  const Text(
                    'Payment Wallets Setup',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Set up your mobile wallets so customers can transfer payments directly to you. These details will be shown to customers at checkout.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  
                  // JazzCash Details
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'JazzCash Wallet',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _jazzcashNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'JazzCash Account Number',
                              prefixIcon: Icon(Icons.phone_android),
                              border: OutlineInputBorder(),
                              hintText: 'e.g. 03001234567',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _jazzcashTitleController,
                            decoration: const InputDecoration(
                              labelText: 'JazzCash Account Title',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                              hintText: 'e.g. Muhammad Irfan',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // EasyPaisa Details
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'EasyPaisa Wallet',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _easypaisaNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'EasyPaisa Account Number',
                              prefixIcon: Icon(Icons.phone_android),
                              border: OutlineInputBorder(),
                              hintText: 'e.g. 03123456789',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _easypaisaTitleController,
                            decoration: const InputDecoration(
                              labelText: 'EasyPaisa Account Title',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                              hintText: 'e.g. Muhammad Irfan',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Reputation Section
                  const Text(
                    'Your Offline Reputation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Since you are new to the app, you can set your starting rating and a featured review from your offline customers.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Initial Rating:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: _initialRating,
                          min: 1.0,
                          max: 5.0,
                          divisions: 4,
                          label: _initialRating.toString(),
                          activeColor: Colors.amber,
                          onChanged: (value) {
                            setState(() {
                              _initialRating = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        '$_initialRating ⭐',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _featuredReviewController,
                    decoration: const InputDecoration(
                      labelText: 'Featured Review (e.g. Best customer service!)',
                      prefixIcon: Icon(Icons.star_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Services
                  const Text(
                    'Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Select the services you offer:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _serviceOptions.map((service) {
                      final isSelected = _selectedServices.contains(service.toLowerCase());
                      return FilterChip(
                        label: Text(service),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            final serviceKey = service.toLowerCase();
                            if (selected) {
                              if (!_selectedServices.contains(serviceKey)) {
                                _selectedServices.add(serviceKey);
                                _pricing[serviceKey] = 0.0;
                              }
                            } else {
                              _selectedServices.remove(serviceKey);
                              _pricing.remove(serviceKey);
                            }
                          });
                        },
                        selectedColor: const Color(0xFF2E7D32),
                        checkmarkColor: const Color(0xFF2E7D32),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Pricing
                  if (_selectedServices.isNotEmpty) ...[
                    const Text(
                      'Pricing',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Set prices for your services:'),
                    const SizedBox(height: 8),
                    ..._selectedServices.map((service) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(child: Text(service[0].toUpperCase() + service.substring(1))),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  prefixText: 'Rs. ',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  _pricing[service.toLowerCase()] =
                                      double.tryParse(value) ?? 0.0;
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                  // Availability
                  const Text(
                    'Availability',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Select your working days:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _dayOptions.map((day) {
                      final isSelected = _availableDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _availableDays.add(day);
                            } else {
                              _availableDays.remove(day);
                            }
                          });
                        },
                        selectedColor: const Color(0xFF2E7D32),
                        checkmarkColor: const Color(0xFF2E7D32),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Time'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _startTime,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: _generateTimeOptions().map((time) {
                                return DropdownMenuItem(
                                  value: time,
                                  child: Text(time),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _startTime = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Time'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _endTime,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: _generateTimeOptions().map((time) {
                                return DropdownMenuItem(
                                  value: time,
                                  child: Text(time),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _endTime = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Work Samples
                  const Text(
                    'Work Samples',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Upload photos of your work (optional):'),
                  const SizedBox(height: 8),
                  if (_workSamples.isEmpty)
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: _pickWorkSamples,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add work samples',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _workSamples.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _workSamples.length) {
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                onTap: _pickWorkSamples,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, color: Colors.grey),
                                    Text(
                                      'Add More',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _workSamples[index],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _workSamples.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Complete Setup Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _completeSetup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Complete Setup',
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
          );
        },
      ),
    );
  }

  List<String> _generateTimeOptions() {
    final List<String> times = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final time =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        times.add(time);
      }
    }
    return times;
  }
}

