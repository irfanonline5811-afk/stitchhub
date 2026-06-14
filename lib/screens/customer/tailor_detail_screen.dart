import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../models/review_model.dart';
import '../../models/tailor_model.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'place_order_screen.dart';
import 'request_measurement_screen.dart';
import 'chat_detail_screen.dart';
import 'share_details_screen.dart';
import '../../services/referral_service.dart';
import 'package:share_plus/share_plus.dart';
import 'book_appointment_screen.dart';
import '../../providers/language_provider.dart';

class TailorDetailScreen extends StatefulWidget {
  final TailorModel tailor;

  const TailorDetailScreen({
    super.key,
    required this.tailor,
  });

  @override
  State<TailorDetailScreen> createState() => _TailorDetailScreenState();
}

class _TailorDetailScreenState extends State<TailorDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    // Load reviews
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewProvider>(context, listen: false)
          .loadReviews(widget.tailor.id);
    });
  }

  Future<void> _loadFavoriteStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);

    if (authProvider.user != null) {
      // Load favorites to check if this tailor is favorited
      await favoriteProvider.loadFavorites(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tailor = widget.tailor;
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: Text(tailor.businessName ?? tailor.name),
        elevation: 0,
        actions: [
          Consumer2<FavoriteProvider, AuthProvider>(
            builder: (context, favoriteProvider, authProvider, child) {
              final isFavorite = favoriteProvider.isFavorite(tailor.id);
              return IconButton(
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? AppTheme.error : AppTheme.white,
                ),
                onPressed: () async {
                  if (authProvider.user != null) {
                    try {
                      await favoriteProvider.toggleFavorite(
                        authProvider.user!.id,
                        tailor.id,
                      );
                      if (context.mounted) {
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
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: AppTheme.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
                tooltip:
                    isFavorite ? 'Remove from favorites' : 'Add to favorites',
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.message_rounded),
                onPressed: () {
                  if (authProvider.user != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          otherUserId: tailor.id,
                          otherUserName: tailor.businessName ?? tailor.name,
                          otherUserImageUrl: tailor.profileImageUrl,
                        ),
                      ),
                    );
                  }
                },
                tooltip: 'Message',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              String? code;
              if (auth.user != null) {
                try {
                  code = await ReferralService()
                      .getOrCreateReferralCode(auth.user!.id);
                } catch (_) {}
              }
              final shareText = StringBuffer()
                ..writeln(
                    'Check out ${tailor.businessName ?? tailor.name} on StitchHub!')
                ..writeln(
                    'Services: ${tailor.services.isNotEmpty ? tailor.services.take(3).join(", ") : 'Tailoring'}')
                ..writeln(
                    'Rating: ${tailor.rating.toStringAsFixed(1)} (${tailor.totalReviews} reviews)')
                ..writeln()
                ..writeln('Download the app to book and order.')
                ..writeln(code != null ? 'Use my referral code: $code' : '');
              Share.share(shareText.toString().trim());
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: tailor.profileImageUrl != null
                        ? CachedNetworkImageProvider(tailor.profileImageUrl!)
                        : null,
                    child: tailor.profileImageUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tailor.businessName ?? tailor.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tailor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingBarIndicator(
                        rating: tailor.rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${tailor.rating.toStringAsFixed(1)} (${tailor.totalReviews} reviews)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (tailor.isAvailable) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        languageProvider.translate('available_now'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.star,
                      title: languageProvider.translate('rating'),
                      value: tailor.rating.toStringAsFixed(1),
                      subtitle: '${tailor.totalReviews} reviews',
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.visibility,
                      title: languageProvider.translate('views'),
                      value: '${(tailor.totalReviews * 10) + 25}',
                      subtitle: 'Profile views',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.check_circle,
                      title: languageProvider.translate('orders'),
                      value: '${(tailor.totalReviews * 5) + 15}',
                      subtitle: 'Completed',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.access_time,
                      title: languageProvider.translate('response'),
                      value: '< 2h',
                      subtitle: 'Avg response time',
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  if (tailor.description != null) ...[
                    Text(
                      languageProvider.translate('about'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tailor.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Services Section
                  Text(
                    languageProvider.translate('services'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tailor.services.map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2E7D32),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          service[0].toUpperCase() + service.substring(1),
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Reviews & Ratings Section
                  Text(
                    languageProvider.translate('reviews'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        reviewProvider.avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (i) {
                              final filled =
                                  (i + 1) <= reviewProvider.avgRating.round();
                              return Icon(
                                filled ? Icons.star : Icons.star_border,
                                color: const Color(0xFFFFB300),
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text('${reviewProvider.ratingCount} reviews',
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (reviewProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (reviewProvider.reviews.isEmpty)
                    const Text('No reviews yet. Be the first to review!',
                        style: TextStyle(color: Colors.grey))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviewProvider.reviews.length.clamp(0, 5),
                      itemBuilder: (context, index) {
                        final ReviewModel r = reviewProvider.reviews[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReviewTile(review: r),
                        );
                      },
                    ),
                  // Pricing Section
                  if (tailor.pricing.isNotEmpty) ...[
                    Text(
                      languageProvider.translate('pricing'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...tailor.pricing.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key[0].toUpperCase() + entry.key.substring(1),
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Rs. ${entry.value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                  // Work Samples Section
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
                              child: CachedNetworkImage(
                                imageUrl: tailor.workSamples[index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Location Section
                  Text(
                    languageProvider.translate('location'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tailor.businessAddress ?? 'Address not provided',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Availability Section
                  Text(
                    languageProvider.isUrdu ? 'دستیابی' : 'Availability',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${tailor.startTime} - ${tailor.endTime}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: tailor.availableDays.map((day) {
                      return Chip(
                        label: Text(day),
                        backgroundColor: const Color(0xFF2E7D32),
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Call functionality coming soon!'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.call_rounded,
                            size: 20, color: Color(0xFF2E7D32)),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            languageProvider.translate('call'),
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              BookAppointmentScreen(tailor: tailor),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 20, color: Color(0xFF2E7D32)),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            languageProvider.translate('book_appointment'),
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              RequestMeasurementScreen(tailor: tailor),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.straighten_rounded,
                            size: 20, color: Color(0xFF2E7D32)),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            languageProvider.translate('measurements'),
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              PlaceOrderScreen(tailor: tailor),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_cart_rounded, size: 20),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            languageProvider.translate('place_order'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ShareDetailsScreen(tailor: tailor),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share),
                    const SizedBox(width: 8),
                    Text(languageProvider.translate('share_my_details')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: review.customerImageUrl != null
                      ? NetworkImage(review.customerImageUrl!)
                      : null,
                  child: review.customerImageUrl == null
                      ? const Icon(Icons.person, size: 18)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: List.generate(5, (i) {
                          final filled = (i + 1) <= review.rating.round();
                          return Icon(
                            filled ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFFB300),
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(review.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.comment),
            ],
            if (review.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(review.images[i],
                        height: 80, width: 80, fit: BoxFit.cover),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: review.images.length,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

