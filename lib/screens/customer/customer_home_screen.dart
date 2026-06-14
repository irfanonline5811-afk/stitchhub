import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../models/order_model.dart';
import 'search_tailors_screen.dart';
import 'my_orders_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'chat_list_screen.dart';
import '../../providers/chat_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'appointments_screen.dart';
import 'order_detail_screen.dart';
import 'chat_detail_screen.dart';
import '../../providers/language_provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
        HomeTab(onSwitchTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        }),
        const MyOrdersScreen(),
        const FavoritesScreen(),
        const ProfileScreen(),
      ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _initializeFavorites();
  }

  Future<void> _initializeLocation() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.getCurrentLocation();
  }

  Future<void> _initializeFavorites() async {
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        key: ValueKey<int>(_currentIndex),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF2E7D32),
              unselectedItemColor: Colors.grey[600],
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              selectedIconTheme: const IconThemeData(size: 28),
              unselectedIconTheme: const IconThemeData(size: 24),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: languageProvider.translate('profile') == 'پروفائل' ? 'ہوم' : 'Home',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  activeIcon: const Icon(Icons.shopping_bag),
                  label: languageProvider.translate('my_orders'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.favorite_border),
                  activeIcon: const Icon(Icons.favorite),
                  label: languageProvider.translate('profile') == 'پروفائل' ? 'پسندیدہ' : 'Favorites',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: languageProvider.translate('profile'),
                ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, this.onSwitchTab});

  final Function(int)? onSwitchTab;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(languageProvider.translate('app_title')),
            actions: [
              TextButton(
                onPressed: () => languageProvider.toggleLanguage(),
                child: Text(
                  languageProvider.isUrdu ? 'EN' : 'اردو',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
            ],
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                if (orderProvider.isLoading) {
                  orderProvider.forceResetLoading();
                  await Future.delayed(const Duration(milliseconds: 100));
                }
                if (authProvider.user != null) {
                  await orderProvider.fetchCustomerOrders(authProvider.user!.id);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1B5E20),
                                Color(0xFF2E7D32),
                                Color(0xFF4CAF50),
                                Color(0xFF66BB6A),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.0, 0.3, 0.7, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.3),
                                          Colors.white.withValues(alpha: 0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Icon(Icons.handshake_outlined, color: Colors.white, size: 32),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          languageProvider.translate('find_tailor'),
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.white.withValues(alpha: 0.95),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          authProvider.user?.name ?? 'Customer',
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    languageProvider.translate('quick_actions'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.search,
                          title: languageProvider.translate('find_tailor'),
                          subtitle: languageProvider.translate('search_hint'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchTailorsScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.event_available,
                          title: languageProvider.translate('appointments'),
                          subtitle: languageProvider.translate('view_or_book'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentsScreen()));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.shopping_bag,
                          title: languageProvider.translate('my_orders'),
                          subtitle: languageProvider.translate('track_order'),
                          onTap: () {
                            if (widget.onSwitchTab != null) widget.onSwitchTab!(1);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.share,
                          title: languageProvider.translate('share_app'),
                          subtitle: languageProvider.translate('invite_friends'),
                          onTap: () {
                            Share.share('Join me on StitchHub! Find great local tailors.');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.favorite,
                          title: languageProvider.translate('my_favorites'),
                          subtitle: languageProvider.translate('saved_tailors'),
                          onTap: () {
                            if (widget.onSwitchTab != null) {
                              widget.onSwitchTab!(2);
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Consumer<ChatProvider>(
                          builder: (context, chatProvider, child) {
                            final recentConvo = chatProvider.conversations.isNotEmpty ? chatProvider.conversations.first : null;
                            final displayTitle = recentConvo != null 
                                ? (recentConvo.userName2 ?? languageProvider.translate('messages_title'))
                                : languageProvider.translate('messages_title');
                            final displaySubtitle = recentConvo != null 
                                ? (recentConvo.lastMessage.length > 30 ? '${recentConvo.lastMessage.substring(0, 27)}...' : recentConvo.lastMessage)
                                : languageProvider.translate('chat_with_tailors');

                            return _QuickActionCard(
                              icon: Icons.chat,
                              title: displayTitle,
                              subtitle: displaySubtitle,
                              imageUrl: recentConvo?.user2ImageUrl,
                              unreadCount: recentConvo?.unreadCount ?? 0,
                              onTap: () {
                                if (recentConvo != null) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(
                                    otherUserId: recentConvo.userId2,
                                    otherUserName: recentConvo.userName2 ?? 'Tailor',
                                    otherUserImageUrl: recentConvo.user2ImageUrl,
                                  )));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen()));
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    languageProvider.translate('recent_orders'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Consumer<OrderProvider>(
                    builder: (context, orderProvider, child) {
                      if (orderProvider.isLoading) return const Center(child: CircularProgressIndicator());
                      if (orderProvider.customerOrders.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              const Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(languageProvider.translate('no_orders_yet'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(languageProvider.translate('place_first_order'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orderProvider.customerOrders.take(3).length,
                        itemBuilder: (context, index) {
                          final order = orderProvider.customerOrders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order))),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF2E7D32),
                                child: Text(order.serviceType[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(order.serviceType, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Order #${order.id.substring(0, 8)}'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: _getStatusColor(order.status), borderRadius: BorderRadius.circular(20)),
                                child: Text(order.status.toString().split('.').last.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusTextColor(order.status))),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange[100]!;
      case OrderStatus.confirmed: return Colors.blue[100]!;
      case OrderStatus.inProgress: return Colors.purple[100]!;
      case OrderStatus.readyForPickup: return Colors.green[100]!;
      case OrderStatus.completed: return Colors.green[200]!;
      case OrderStatus.cancelled: return Colors.red[100]!;
      default: return Colors.grey[100]!;
    }
  }

  Color _getStatusTextColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange[900]!;
      case OrderStatus.confirmed: return Colors.blue[900]!;
      case OrderStatus.inProgress: return Colors.purple[900]!;
      case OrderStatus.readyForPickup: return Colors.green[900]!;
      case OrderStatus.completed: return Colors.green[900]!;
      case OrderStatus.cancelled: return Colors.red[900]!;
      default: return Colors.grey[900]!;
    }
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? imageUrl;
  final int unreadCount;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.imageUrl,
    this.unreadCount = 0,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: widget.imageUrl != null ? EdgeInsets.zero : const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: widget.imageUrl != null ? null : const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: widget.imageUrl != null 
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(widget.imageUrl!, width: 52, height: 52, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(widget.icon, size: 28, color: Colors.white)),
                                )
                              : Icon(widget.icon, size: 28, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.title, 
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)), 
                            textAlign: TextAlign.center, 
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle, 
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]), 
                            textAlign: TextAlign.center, 
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.unreadCount > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                        child: Text('${widget.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
