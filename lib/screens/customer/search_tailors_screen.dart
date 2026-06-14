import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/tailor_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/tailor_model.dart';
import '../../widgets/modern_ui_components.dart';
import '../../theme/app_theme.dart';
import 'tailor_detail_screen.dart';
import '../../models/search_filter_model.dart';

class SearchTailorsScreen extends StatefulWidget {
  const SearchTailorsScreen({super.key});

  @override
  State<SearchTailorsScreen> createState() => _SearchTailorsScreenState();
}

class _SearchTailorsScreenState extends State<SearchTailorsScreen> {
  final _searchController = TextEditingController();
  String _selectedService = 'All';
  double _selectedRadius = 10.0;
  double _selectedMinRating = 0.0;
  double _selectedMaxPrice = 10000.0;
  Timer? _debounce;

  final List<String> _services = [
    'All',
    'Shirt',
    'Pants',
    'Dress',
    'Suit',
    'Kurta',
    'Saree',
    'Coat',
    'Skirt',
  ];

  @override
  void initState() {
    super.initState();
    _searchNearbyTailors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchNearbyTailors();
    });
  }

  Future<void> _searchNearbyTailors() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final tailorProvider = Provider.of<TailorProvider>(context, listen: false);

      // Provide a fallback if GPS is turned off or permission is denied
      // so users can still search manually.
      final lat = locationProvider.currentPosition?.latitude ?? 0.0;
      final lng = locationProvider.currentPosition?.longitude ?? 0.0;

      await tailorProvider.searchTailors(
        latitude: lat,
        longitude: lng,
        radiusKm: _selectedRadius,
        serviceType:
            _selectedService == 'All' ? null : _selectedService.toLowerCase(),
        minRating: _selectedMinRating > 0 ? _selectedMinRating : null,
        searchQuery: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: Text(Provider.of<LanguageProvider>(context).translate('find_tailor')),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showFilterDialog,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar with modern design
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: ModernSearchBar(
              controller: _searchController,
              hintText: Provider.of<LanguageProvider>(context).translate('search_hint'),
              onChanged: _onSearchChanged,
              onClear: () {
                _onSearchChanged('');
              },
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: Row(
              children: [
                ModernFilterChip(
                  label: 'All Services',
                  icon: Icons.apps_rounded,
                  isSelected: _selectedService == 'All',
                  onSelected: () {
                    setState(() {
                      _selectedService = 'All';
                    });
                    _searchNearbyTailors();
                  },
                ),
                const SizedBox(width: AppTheme.spacing8),
                ..._services.skip(1).map((service) => Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacing8),
                      child: ModernFilterChip(
                        label: service,
                        isSelected: _selectedService == service,
                        onSelected: () {
                          setState(() {
                            _selectedService = service;
                          });
                          _searchNearbyTailors();
                        },
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          // Budget Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: Row(
              children: [
                _BudgetFilterChip(
                  label: Provider.of<LanguageProvider>(context).translate('sasta'),
                  icon: Icons.savings_outlined,
                  isSelected: _selectedMaxPrice == 1500.0,
                  onSelected: () {
                    setState(() {
                      _selectedMaxPrice = 1500.0;
                    });
                    _searchNearbyTailors();
                  },
                ),
                const SizedBox(width: AppTheme.spacing8),
                _BudgetFilterChip(
                  label: Provider.of<LanguageProvider>(context).translate('standard'),
                  icon: Icons.straighten_outlined,
                  isSelected: _selectedMaxPrice == 5000.0,
                  onSelected: () {
                    setState(() {
                      _selectedMaxPrice = 5000.0;
                    });
                    _searchNearbyTailors();
                  },
                ),
                const SizedBox(width: AppTheme.spacing8),
                _BudgetFilterChip(
                  label: Provider.of<LanguageProvider>(context).translate('designer'),
                  icon: Icons.diamond_outlined,
                  isSelected: _selectedMaxPrice == 20000.0,
                  onSelected: () {
                    setState(() {
                      _selectedMaxPrice = 20000.0;
                    });
                    _searchNearbyTailors();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          // Tailors List
          Expanded(
            child: Consumer<TailorProvider>(
              builder: (context, tailorProvider, child) {
                if (tailorProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                    ),
                  );
                }

                if (tailorProvider.error != null) {
                  return ModernEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Error Loading Tailors',
                    subtitle: tailorProvider.error,
                    buttonText: 'Retry',
                    onButtonTap: _searchNearbyTailors,
                  );
                }

                if (tailorProvider.nearbyTailors.isEmpty) {
                  return ModernEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No Tailors Found',
                    subtitle: 'Try adjusting your search criteria or filters',
                    buttonText: 'Clear Filters',
                    onButtonTap: () {
                      setState(() {
                        _selectedService = 'All';
                        _selectedRadius = 10.0;
                        _selectedMinRating = 0.0;
                      });
                      _searchNearbyTailors();
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: _searchNearbyTailors,
                  color: AppTheme.primaryGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    itemCount: tailorProvider.nearbyTailors.length,
                    itemBuilder: (context, index) {
                      final tailor = tailorProvider.nearbyTailors[index];
                      return AnimatedFadeIn(
                        delay: index * 0.1,
                        child: _TailorCard(
                          tailor: tailor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    TailorDetailScreen(tailor: tailor),
                              ),
                            );
                          },
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
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Tailors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Radius Filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Search Radius',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gray900,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_selectedRadius.toInt()} km',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.primaryGreen,
                          inactiveTrackColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          thumbColor: AppTheme.primaryGreen,
                          overlayColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _selectedRadius,
                          min: 1.0,
                          max: 50.0,
                          divisions: 49,
                          onChanged: (value) {
                            setState(() {
                              _selectedRadius = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Rating Filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Minimum Rating',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gray900,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentAmber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_selectedMinRating.toStringAsFixed(1)} ★',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.accentAmber,
                          thumbColor: AppTheme.accentAmber,
                        ),
                        child: Slider(
                          value: _selectedMinRating,
                          min: 0.0,
                          max: 5.0,
                          divisions: 50,
                          onChanged: (value) {
                            setState(() {
                              _selectedMinRating = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Price Filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Max Price',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gray900,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Rs. ${_selectedMaxPrice.toInt()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.blue,
                          thumbColor: Colors.blue,
                        ),
                        child: Slider(
                          value: _selectedMaxPrice,
                          min: 500,
                          max: 20000,
                          divisions: 39,
                          onChanged: (value) {
                            setState(() {
                              _selectedMaxPrice = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Sort By
                      const Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gray900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Consumer<TailorProvider>(
                        builder: (context, provider, _) {
                          TailorSortBy current = provider.filters.sortBy;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.gray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.gray200, width: 1),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<TailorSortBy>(
                                value: current,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.gray600),
                                items: const [
                                  DropdownMenuItem(value: TailorSortBy.relevance, child: Text('Relevance')),
                                  DropdownMenuItem(value: TailorSortBy.ratingDesc, child: Text('Rating (High to Low)')),
                                  DropdownMenuItem(value: TailorSortBy.distanceAsc, child: Text('Distance (Near to Far)')),
                                  DropdownMenuItem(value: TailorSortBy.priceAsc, child: Text('Price (Low to High)')),
                                ],
                                onChanged: (val) {
                                  if (val == null) return;
                                  final loc = Provider.of<LocationProvider>(context, listen: false);
                                  provider.setFilters(
                                    provider.filters.copyWith(sortBy: val),
                                    latitude: loc.currentPosition?.latitude,
                                    longitude: loc.currentPosition?.longitude,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: ModernButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernButton(
                        text: 'Apply',
                        icon: Icons.check_rounded,
                        onPressed: () {
                          Navigator.of(context).pop();
                          final provider = Provider.of<TailorProvider>(context, listen: false);
                          final loc = Provider.of<LocationProvider>(context, listen: false);
                          provider.setFilters(
                            provider.filters.copyWith(
                              minRating: _selectedMinRating > 0 ? _selectedMinRating : null,
                              maxPrice: _selectedMaxPrice < 20000 ? _selectedMaxPrice : null,
                            ),
                            latitude: loc.currentPosition?.latitude,
                            longitude: loc.currentPosition?.longitude,
                          );
                          _searchNearbyTailors();
                        },
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
}

class _TailorCard extends StatelessWidget {
  final TailorModel tailor;
  final VoidCallback onTap;

  const _TailorCard({
    required this.tailor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: tailor.profileImageUrl != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        child: Image.network(
                          tailor.profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person_rounded,
                              size: 35,
                              color: AppTheme.white,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 35,
                        color: AppTheme.white,
                      ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tailor.businessName ?? tailor.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gray900,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (tailor.isAvailable) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.success,
                                  AppTheme.successLight
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppTheme.success.withValues(alpha: 0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: AppTheme.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Available',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (tailor.rating > 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.accentAmber,
                                  AppTheme.accentOrange
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppTheme.accentAmber.withValues(alpha: 0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: AppTheme.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tailor.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.gray100,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Text(
                              '${tailor.totalReviews} reviews',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.gray700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade700,
                                  Colors.blue.shade400
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: AppTheme.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'New Tailor',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Be the first to rate!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tailor.description != null) ...[
            const SizedBox(height: AppTheme.spacing16),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                tailor.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray700,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacing16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppTheme.gray700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tailor.businessAddress ?? 'Address not provided',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (tailor.services.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tailor.services.take(3).map((service) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen.withValues(alpha: 0.1),
                        AppTheme.primaryGreenLight.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    service[0].toUpperCase() + service.substring(1),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;

  const _BudgetFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppTheme.primaryGreen,
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppTheme.primaryGreen,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.gray700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.gray300,
        ),
      ),
    );
  }
}
