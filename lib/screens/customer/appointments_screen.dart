import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment_model.dart';
import '../../widgets/modern_ui_components.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../utils/url_utils.dart';
import '../../models/user_model.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      await Provider.of<AppointmentProvider>(context, listen: false)
          .loadCustomerAppointments(auth.user!.id);
    }
  }

  void _showAppointmentDetails(AppointmentModel appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Appointment Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              _DetailItem(
                icon: Icons.store,
                label: 'Tailor',
                value: appointment.tailorName,
              ),
              _DetailItem(
                icon: Icons.calendar_today,
                label: 'Date',
                value: DateFormat('EEEE, d MMMM yyyy')
                    .format(appointment.startTime),
              ),
              _DetailItem(
                icon: Icons.access_time,
                label: 'Time',
                value:
                    '${DateFormat('hh:mm a').format(appointment.startTime)} - ${DateFormat('hh:mm a').format(appointment.endTime)}',
              ),
              _DetailItem(
                icon: Icons.info_outline,
                label: 'Status',
                value: appointment.status.name.toUpperCase(),
                valueColor: _getStatusColor(appointment.status),
              ),
              if (appointment.notes != null && appointment.notes!.isNotEmpty)
                _DetailItem(
                  icon: Icons.note,
                  label: 'My Notes',
                  value: appointment.notes!,
                  isLongText: true,
                ),
              const SizedBox(height: 16),
              FutureBuilder<UserModel?>(
                future: AuthService().getUserProfile(appointment.tailorId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final tailorPhone = snapshot.data!.phone;
                    return Row(
                      children: [
                        Expanded(
                          child: ModernButton(
                            text: 'Call Tailor',
                            icon: Icons.phone,
                            onPressed: () => UrlUtils.makeCall(tailorPhone),
                            backgroundColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernButton(
                            text: 'WhatsApp',
                            icon: Icons.message,
                            onPressed: () => UrlUtils.openWhatsApp(
                                tailorPhone, 
                                "Hi ${appointment.tailorName}, I'm calling about my appointment on ${DateFormat('MMM d').format(appointment.startTime)}."
                            ),
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),
              if (appointment.status == AppointmentStatus.pending)
                ModernButton(
                  text: 'Cancel Appointment',
                  onPressed: () {
                    Provider.of<AppointmentProvider>(context, listen: false)
                        .cancel(appointment.id);
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.red,
                  isOutlined: true,
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.approved:
        return Colors.green;
      case AppointmentStatus.declined:
        return Colors.red;
      case AppointmentStatus.cancelled:
        return Colors.grey;
      case AppointmentStatus.completed:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text('My Appointments'),
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.customerAppointments.isEmpty) {
            return const ModernEmptyState(
              icon: Icons.event_note,
              title: 'No Appointments',
              subtitle: 'You haven\'t booked any appointments yet',
            );
          }
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.customerAppointments.length,
              itemBuilder: (_, i) {
                final a = provider.customerAppointments[i];
                return ModernCard(
                  onTap: () => _showAppointmentDetails(a),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _getStatusColor(a.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.event,
                          color: _getStatusColor(a.status),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.tailorName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('MMM d').format(a.startTime)} • ${DateFormat('hh:mm a').format(a.startTime)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ModernStatusBadge(
                        status: a.status.name,
                        backgroundColor:
                            _getStatusColor(a.status).withValues(alpha: 0.1),
                        textColor: _getStatusColor(a.status),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
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

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLongText;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLongText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment:
            isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.grey[700], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

