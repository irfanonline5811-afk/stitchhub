import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/modern_ui_components.dart';
import '../../widgets/city_selection_dialog.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'tailor_setup_screen.dart';

class TailorProfileScreen extends StatefulWidget {
  const TailorProfileScreen({super.key});

  @override
  State<TailorProfileScreen> createState() => _TailorProfileScreenState();
}

class _TailorProfileScreenState extends State<TailorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _expertiseController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _jazzcashNumberController = TextEditingController();
  final _jazzcashTitleController = TextEditingController();
  final _easypaisaNumberController = TextEditingController();
  final _easypaisaTitleController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  final List<String> _selectedServices = [];
  final Map<String, double> _pricing = {};
  
  final List<String> _serviceOptions = [
    'shirt',
    'pants',
    'dress',
    'suit',
    'kurta',
    'saree',
    'coat',
    'skirt',
  ];

  @override
  void initState() {
    super.initState();
    _loadTailorData();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _expertiseController.dispose();
    _basePriceController.dispose();
    _descriptionController.dispose();
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

  void _loadTailorData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.tailor != null) {
      final tailor = authProvider.tailor!;
      _businessNameController.text = tailor.businessName ?? '';
      _businessAddressController.text = tailor.businessAddress ?? '';
      _expertiseController.text = tailor.specialties.join(', ');
      _basePriceController.text = tailor.basePrice ?? '';
      _descriptionController.text = tailor.description ?? '';
      _jazzcashNumberController.text = tailor.jazzcashNumber ?? '';
      _jazzcashTitleController.text = tailor.jazzcashTitle ?? '';
      _easypaisaNumberController.text = tailor.easypaisaNumber ?? '';
      _easypaisaTitleController.text = tailor.easypaisaTitle ?? '';
      _selectedServices.clear();
      _selectedServices.addAll(tailor.services);
      _pricing.clear();
      _pricing.addAll(tailor.pricing);
    }
  }

  Future<void> _pickImage() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        final authService = AuthService();
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Show loading
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            ),
          ),
        );

        // Upload image
        final imageUrl = await authService.uploadProfileImage(
          File(image.path),
          authProvider.user!.id,
        );

        // Update profile
        await authProvider.updateProfile(profileImageUrl: imageUrl);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(languageProvider.translate('profile_image_updated')),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${languageProvider.translate('error_updating_image')}$e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

      if (authProvider.tailor != null) {
        final updatedTailor = authProvider.tailor!.copyWithTailor(
          businessName: _businessNameController.text.trim(),
          businessAddress: _businessAddressController.text.trim(),
          specialties: _expertiseController.text.trim().isNotEmpty
              ? _expertiseController.text
                  .split(',')
                  .map((e) => e.trim())
                  .toList()
              : [],
          basePrice: _basePriceController.text.trim(),
          description: _descriptionController.text.trim(),
          services: _selectedServices,
          pricing: _pricing,
          jazzcashNumber: _jazzcashNumberController.text.trim(),
          jazzcashTitle: _jazzcashTitleController.text.trim(),
          easypaisaNumber: _easypaisaNumberController.text.trim(),
          easypaisaTitle: _easypaisaTitleController.text.trim(),
        );

        await authProvider.updateTailorProfile(updatedTailor);

        if (mounted) {
          setState(() {
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(languageProvider.translate('profile_updated')),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: Text(languageProvider.translate('profile')),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: languageProvider.translate('edit_profile'),
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            );
          }

          if (authProvider.user == null) {
            return const Center(child: Text("User session not found. Please log in again."));
          }

          if (authProvider.tailor == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: AppTheme.error),
                  const SizedBox(height: 16),
                  const Text('Profile data not found or incomplete.'),
                  const SizedBox(height: 8),
                  if (authProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        authProvider.error!,
                        style: const TextStyle(color: AppTheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const TailorSetupScreen(),
                        ),
                      );
                    },
                    child: const Text('Complete Setup'),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: AppTheme.error),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppTheme.error),
                    ),
                  ),
                ],
              ),
            );
          }

          final tailor = authProvider.tailor!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture
                  AnimatedFadeIn(
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.primaryGreen,
                                  AppTheme.primaryGreenLight,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: tailor.profileImageUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      tailor.profileImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.person_rounded,
                                          size: 60,
                                          color: AppTheme.white,
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    size: 60,
                                    color: AppTheme.white,
                                  ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _pickImage,
                                  icon: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: AppTheme.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  // Basic Info
                  AnimatedFadeIn(
                    delay: 0.1,
                    child: Text(
                      tailor.businessName ?? tailor.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedFadeIn(
                    delay: 0.2,
                    child: Text(
                      tailor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  // Business Information
                  AnimatedFadeIn(
                    delay: 0.3,
                    child: ModernSectionHeader(title: languageProvider.translate('business_info')),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  AnimatedFadeIn(
                    delay: 0.4,
                    child: ModernTextField(
                      controller: _businessNameController,
                      labelText: languageProvider.translate('business_name'),
                      prefixIcon: Icons.business_rounded,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return languageProvider.translate('enter_business_name');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  AnimatedFadeIn(
                    delay: 0.5,
                    child: GestureDetector(
                      onTap: _isEditing
                          ? () {
                              showDialog(
                                context: context,
                                builder: (context) => CitySelectionDialog(
                                  cities: _pkCities,
                                  onCitySelected: (selectedCity) {
                                    setState(() {
                                      _businessAddressController.text =
                                          selectedCity;
                                    });
                                  },
                                ),
                              );
                            }
                          : null,
                      child: AbsorbPointer(
                        absorbing: _isEditing,
                        child: ModernTextField(
                          controller: _businessAddressController,
                          labelText: languageProvider.translate('city'),
                          prefixIcon: Icons.search_rounded,
                          enabled: _isEditing,
                          maxLines: 1,
                          hintText: languageProvider.translate('tap_select_city'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.translate('enter_city');
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  const SizedBox(height: AppTheme.spacing16),
                  AnimatedFadeIn(
                    delay: 0.6,
                    child: ModernTextField(
                      controller: _expertiseController,
                      labelText: languageProvider.translate('expertise'),
                      prefixIcon: Icons.content_cut_rounded,
                      enabled: _isEditing,
                      validator: (value) => null,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  AnimatedFadeIn(
                    delay: 0.7,
                    child: ModernTextField(
                      controller: _basePriceController,
                      labelText: languageProvider.translate('base_pricing'),
                      prefixWidget: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'PKR',
                          style: TextStyle(
                            color: AppTheme.gray700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      enabled: _isEditing,
                      validator: (value) => null,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  AnimatedFadeIn(
                    delay: 0.8,
                    child: ModernTextField(
                      controller: _descriptionController,
                      labelText: languageProvider.translate('description'),
                      prefixIcon: Icons.description_rounded,
                      enabled: _isEditing,
                      maxLines: 3,
                      hintText: languageProvider.translate('tell_customers'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Payment Wallets Setup Section
                  const AnimatedFadeIn(
                    delay: 0.9,
                    child: ModernSectionHeader(title: 'Payment Wallets Setup'),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  AnimatedFadeIn(
                    delay: 1.0,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Set up your mobile wallets so customers can transfer payments directly to you. These details will be shown to customers at checkout.',
                              style: TextStyle(color: AppTheme.gray600, fontSize: 13),
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            
                            // JazzCash Section
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet_rounded, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'JazzCash Wallet',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing12),
                            ModernTextField(
                              controller: _jazzcashNumberController,
                              labelText: 'JazzCash Account Number',
                              prefixIcon: Icons.phone_android_rounded,
                              enabled: _isEditing,
                              keyboardType: TextInputType.phone,
                              hintText: 'e.g. 03001234567',
                            ),
                            const SizedBox(height: AppTheme.spacing12),
                            ModernTextField(
                              controller: _jazzcashTitleController,
                              labelText: 'JazzCash Account Title',
                              prefixIcon: Icons.person_outline_rounded,
                              enabled: _isEditing,
                              hintText: 'e.g. Muhammad Irfan',
                            ),
                            
                            const Divider(height: 32),
                            
                            // EasyPaisa Section
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet_rounded, color: Colors.green[700]),
                                const SizedBox(width: 8),
                                const Text(
                                  'EasyPaisa Wallet',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing12),
                            ModernTextField(
                              controller: _easypaisaNumberController,
                              labelText: 'EasyPaisa Account Number',
                              prefixIcon: Icons.phone_android_rounded,
                              enabled: _isEditing,
                              keyboardType: TextInputType.phone,
                              hintText: 'e.g. 03123456789',
                            ),
                            const SizedBox(height: AppTheme.spacing12),
                            ModernTextField(
                              controller: _easypaisaTitleController,
                              labelText: 'EasyPaisa Account Title',
                              prefixIcon: Icons.person_outline_rounded,
                              enabled: _isEditing,
                              hintText: 'e.g. Muhammad Irfan',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!_isEditing && 
                      (tailor.jazzcashNumber == null || tailor.jazzcashNumber!.isEmpty) && 
                      (tailor.easypaisaNumber == null || tailor.easypaisaNumber!.isEmpty)) ...[
                    const SizedBox(height: AppTheme.spacing12),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.amber[800]),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Please edit your profile to add JazzCash or EasyPaisa details so customers can pay you online!',
                              style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Services
                  Text(
                    languageProvider.translate('services'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_isEditing)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _serviceOptions.map((service) {
                        final isSelected = _selectedServices.contains(service);
                        return FilterChip(
                          label: Text(service[0].toUpperCase() + service.substring(1)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (!_selectedServices.contains(service)) {
                                  _selectedServices.add(service);
                                  _pricing[service] = 0.0;
                                }
                              } else {
                                _selectedServices.remove(service);
                                _pricing.remove(service);
                              }
                            });
                          },
                          selectedColor: AppTheme.primaryGreen,
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    )
                  else if (tailor.services.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tailor.services.map((service) {
                        return Chip(
                          label: Text(service[0].toUpperCase() + service.substring(1)),
                          backgroundColor: const Color(0xFF2E7D32),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        languageProvider.translate('no_services_added'),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Pricing
                  if (tailor.pricing.isNotEmpty) ...[
                    Text(
                      languageProvider.translate('pricing'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isEditing)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: _selectedServices.map((service) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(service[0].toUpperCase() + service.substring(1))),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 120,
                                      child: ModernTextField(
                                        initialValue: (_pricing[service] ?? 0.0).toStringAsFixed(0),
                                        keyboardType: TextInputType.number,
                                        prefixIcon: Icons.payments_rounded,
                                        onChanged: (value) {
                                          _pricing[service] = double.tryParse(value) ?? 0.0;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: tailor.pricing.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.key[0].toUpperCase() + entry.key.substring(1),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Rs. ${entry.value.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                  // Work Samples
                  if (tailor.workSamples.isNotEmpty) ...[
                    Text(
                      languageProvider.translate('work_samples'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tailor.workSamples.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                tailor.workSamples[index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Action Buttons
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _loadTailorData(); // Reset form
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(languageProvider.translate('cancel')),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                authProvider.isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: authProvider.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(languageProvider.translate('save')),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: authProvider.isLoading ? null : _signOut,
                      icon: authProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.logout),
                      label: Text(
                        authProvider.isLoading ? '${languageProvider.translate('sign_out')}...' : languageProvider.translate('sign_out'),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.red),
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
}


