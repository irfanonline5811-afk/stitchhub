import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/modern_ui_components.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'settings/notifications_screen.dart';
import 'settings/privacy_screen.dart';
import 'settings/help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _nameController.text = authProvider.user!.name;
      _phoneController.text = authProvider.user!.phone;
      _emailController.text = authProvider.user!.email;
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
        await authProvider.updateProfile(
          profileImageUrl: imageUrl,
        );

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

      await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

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
          if (authProvider.user == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture with modern design
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
                                  AppTheme.primaryGreenLight
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGreen
                                      .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: authProvider.user!.profileImageUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      authProvider.user!.profileImageUrl!,
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
                                      color: AppTheme.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen
                                          .withValues(alpha: 0.4),
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
                  const SizedBox(height: AppTheme.spacing32),
                  // Profile Form with modern fields
                  AnimatedFadeIn(
                    delay: 0.1,
                    child: ModernTextField(
                      controller: _nameController,
                      labelText: languageProvider.translate('full_name'),
                      prefixIcon: Icons.person_outline_rounded,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return languageProvider.translate('enter_name');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  AnimatedFadeIn(
                    delay: 0.2,
                    child: ModernTextField(
                      controller: _emailController,
                      labelText: languageProvider.translate('email'),
                      prefixIcon: Icons.email_outlined,
                      enabled: false,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  AnimatedFadeIn(
                    delay: 0.3,
                    child: ModernTextField(
                      controller: _phoneController,
                      labelText: languageProvider.translate('phone_number'),
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return languageProvider.translate('enter_phone');
                        }
                        if (value.length < 10) {
                          return languageProvider.translate('valid_phone');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing32),
                  // Action Buttons
                  if (_isEditing) ...[
                    AnimatedFadeIn(
                      delay: 0.4,
                      child: Row(
                        children: [
                          Expanded(
                            child: ModernButton(
                              text: languageProvider.translate('cancel'),
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _loadUserData();
                                });
                              },
                              isOutlined: true,
                              backgroundColor: AppTheme.gray600,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing16),
                          Expanded(
                            child: ModernButton(
                              text: languageProvider.translate('save'),
                              icon: Icons.check_rounded,
                              onPressed:
                                  authProvider.isLoading ? null : _saveProfile,
                              isLoading: authProvider.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing32),
                  ],
                  // Settings Section
                  AnimatedFadeIn(
                    delay: 0.5,
                    child: ModernSectionHeader(
                      title: languageProvider.translate('settings'),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: languageProvider.translate('notifications'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  Consumer<LanguageProvider>(
                    builder: (context, languageProvider, _) {
                      return _SettingsTile(
                        icon: Icons.language_rounded,
                        title: languageProvider.isUrdu ? 'زبان (اردو)' : 'Language (English)',
                        subtitle: languageProvider.isUrdu ? 'انگریزی میں تبدیل کریں' : 'Switch to Urdu',
                        onTap: () {
                          languageProvider.toggleLanguage();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(languageProvider.isUrdu ? 'زبان اردو کر دی گئی ہے' : 'Language switched to English'),
                              backgroundColor: AppTheme.primaryGreen,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: languageProvider.translate('privacy'),
                    subtitle: languageProvider.translate('manage_privacy'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: languageProvider.translate('help_support'),
                    subtitle: languageProvider.translate('get_help'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: languageProvider.translate('about'),
                    subtitle: languageProvider.translate('app_version_info'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLarge),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacing24),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLarge),
                              color: AppTheme.white,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.all(AppTheme.spacing16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.info_rounded,
                                    color: AppTheme.primaryGreen,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing20),
                                Text(
                                  languageProvider.translate('about_stitchhub'),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.gray900,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing16),
                                Text(
                                  '${languageProvider.translate('version')} 1.0.0',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.gray700,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing8),
                                Text(
                                  languageProvider.translate('connect_tailors'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.gray600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppTheme.spacing24),
                                ModernButton(
                                  text: languageProvider.translate('ok'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing32),
                  // Sign Out Button
                  AnimatedFadeIn(
                    delay: 0.6,
                    child: SizedBox(
                      width: double.infinity,
                      child: ModernButton(
                        text: languageProvider.translate('sign_out'),
                        icon: Icons.logout_rounded,
                        onPressed: authProvider.isLoading ? null : _signOut,
                        isLoading: authProvider.isLoading,
                        backgroundColor: AppTheme.error,
                        isOutlined: true,
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle = '',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTheme.gray400,
          ),
        ],
      ),
    );
  }
}

