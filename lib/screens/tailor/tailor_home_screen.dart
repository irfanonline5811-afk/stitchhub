import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/order_model.dart';
import 'tailor_orders_screen.dart';
import 'tailor_profile_screen.dart';
import 'tailor_measurement_requests_screen.dart';
import 'tailor_appointments_screen.dart';
import 'tailor_chat_list_screen.dart';
import 'add_customer_measurement_screen.dart';
import 'order_detail_screen.dart';

class TailorHomeScreen extends StatefulWidget {
  const TailorHomeScreen({super.key});

  @override
  State<TailorHomeScreen> createState() => _TailorHomeScreenState();
}

class _TailorHomeScreenState extends State<TailorHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const TailorOrdersScreen(),
    const TailorMeasurementRequestsScreen(),
    const TailorProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
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
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xFF2E7D32),
                unselectedItemColor: Colors.grey[600],
                backgroundColor: Colors.white,
                items: [
                  BottomNavigationBarItem(icon: const Icon(Icons.dashboard_outlined), activeIcon: const Icon(Icons.dashboard), label: languageProvider.translate('dashboard')),
                  BottomNavigationBarItem(icon: const Icon(Icons.work_outline), activeIcon: const Icon(Icons.work), label: languageProvider.translate('orders')),
                  BottomNavigationBarItem(icon: const Icon(Icons.straighten_outlined), activeIcon: const Icon(Icons.straighten), label: languageProvider.translate('measurements')),
                  BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: languageProvider.translate('profile')),
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
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${languageProvider.translate('app_title')} Tailor'),
        actions: [
          TextButton(
            onPressed: () => languageProvider.toggleLanguage(),
            child: Text(languageProvider.isUrdu ? 'EN' : 'اردو', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.5), blurRadius: 25, offset: const Offset(0, 12))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(18)),
                              child: const Icon(Icons.business_center, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(languageProvider.translate('welcome_back'), style: TextStyle(fontSize: 17, color: Colors.white.withValues(alpha: 0.95), fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(authProvider.user?.name ?? 'Tailor', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up, color: Colors.white, size: 20),
                              const SizedBox(width: 14),
                              Expanded(child: Text(languageProvider.translate('manage_orders_grow_business'), style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(languageProvider.translate('quick_actions'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.work,
                      title: languageProvider.translate('view_orders'),
                      subtitle: languageProvider.translate('manage_your_orders'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TailorOrdersScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.event,
                      title: languageProvider.translate('appointments'),
                      subtitle: languageProvider.translate('approve_or_decline'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TailorAppointmentsScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.person_add,
                      title: languageProvider.translate('add_customer'),
                      subtitle: languageProvider.translate('add_customer_measurements'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustomerMeasurementScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.straighten,
                      title: languageProvider.translate('measurements'),
                      subtitle: languageProvider.translate('view_measurement_requests'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TailorMeasurementRequestsScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.chat,
                      title: languageProvider.translate('messages_title'),
                      subtitle: languageProvider.translate('chat_with_customers'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TailorChatListScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 32),
              Text(languageProvider.translate('recent_orders'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  if (orderProvider.isLoading) return const Center(child: CircularProgressIndicator());
                  if (orderProvider.tailorOrders.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(languageProvider.translate('no_orders_yet'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderProvider.tailorOrders.take(3).length,
                    itemBuilder: (context, index) {
                      final order = orderProvider.tailorOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TailorOrderDetailScreen(order: order))),
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

  const _QuickActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

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
            boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(widget.icon, size: 28, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(widget.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)), textAlign: TextAlign.center, maxLines: 2),
                      const SizedBox(height: 4),
                      Text(widget.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center, maxLines: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
