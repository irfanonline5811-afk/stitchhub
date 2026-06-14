import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/tailor_model.dart';
import '../../widgets/modern_ui_components.dart';
import '../../theme/app_theme.dart';
import 'tailor_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);

    if (authProvider.user != null) {
      await favoriteProvider.loadFavorites(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('My Favorites'),
        elevation: 0,
      ),
      body: Consumer2<FavoriteProvider, AuthProvider>(
        builder: (context, favoriteProvider, authProvider, child) {
          if (favoriteProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            );
          }

          if (favoriteProvider.error != null) {
            return ModernEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Error Loading Favorites',
              subtitle: favoriteProvider.error,
              buttonText: 'Retry',
              onButtonTap: _loadFavorites,
            );
          }

          if (favoriteProvider.favoriteTailors.isEmpty) {
            return const ModernEmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No Favorites Yet',
              subtitle:
                  'Tap the heart icon on tailor profiles\nto add them to your favorites',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadFavorites,
            color: AppTheme.primaryGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: favoriteProvider.favoriteTailors.length,
              itemBuilder: (context, index) {
                final tailor = favoriteProvider.favoriteTailors[index];
                return AnimatedFadeIn(
                  delay: index * 0.1,
                  child: _FavoriteTailorCard(
                    tailor: tailor,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              TailorDetailScreen(tailor: tailor),
                        ),
                      );
                    },
                    onFavoriteToggle: () async {
                      if (authProvider.user != null) {
                        try {
                          await favoriteProvider.toggleFavorite(
                            authProvider.user!.id,
                            tailor.id,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                favoriteProvider.isFavorite(tailor.id)
                                    ? 'Added to favorites'
                                    : 'Removed from favorites',
                              ),
                              backgroundColor: AppTheme.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: AppTheme.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    isFavorite: favoriteProvider.isFavorite(tailor.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteTailorCard extends StatelessWidget {
  final TailorModel tailor;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  const _FavoriteTailorCard({
    required this.tailor,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
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
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Image.network(
                      tailor.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: AppTheme.white,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    size: 30,
                    color: AppTheme.white,
                  ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tailor.businessName ?? tailor.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gray900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  tailor.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.accentAmber, AppTheme.accentOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
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
                          horizontal: 8, vertical: 4),
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
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? AppTheme.error : AppTheme.gray400,
              size: 28,
            ),
            onPressed: onFavoriteToggle,
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
    );
  }
}

