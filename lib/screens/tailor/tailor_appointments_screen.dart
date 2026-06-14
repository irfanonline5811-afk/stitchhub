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

class TailorAppointmentsScreen extends StatefulWidget {
  const TailorAppointmentsScreen({super.key});

  @override
  State<TailorAppointmentsScreen> createState() =>
      _TailorAppointmentsScreenState();
}

class _TailorAppointmentsScreenState extends State<TailorAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      await Provider.of<AppointmentProvider>(context, listen: false)
          .loadTailorAppointments(auth.user!.id);
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
                icon: Icons.person,
                label: 'Customer',
                value: appointment.customerName,
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
                  label: 'Notes',
                  value: appointment.notes!,
                  isLongText: true,
                ),
              const SizedBox(height: 32),
              if (appointment.status == AppointmentStatus.pending)
                Row(
                  children: [
                    Expanded(
                      child: ModernButton(
                        text: 'Decline',
                        onPressed: () {
                          Provider.of<AppointmentProvider>(context,
                                  listen: false)
                              .decline(appointment.id);
                          Navigator.pop(context);
                        },
                        backgroundColor: Colors.red,
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernButton(
                        text: 'Approve',
                        onPressed: () {
                          Provider.of<AppointmentProvider>(context,
                                  listen: false)
                              .approve(appointment.id);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              FutureBuilder<UserModel?>(
                future: AuthService().getUserProfile(appointment.customerId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final customerPhone = snapshot.data!.phone;
                    return Row(
                      children: [
                        Expanded(
                          child: ModernButton(
                            text: 'Call Customer',
                            icon: Icons.phone,
                            onPressed: () => UrlUtils.makeCall(customerPhone),
                            backgroundColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernButton(
                            text: 'WhatsApp',
                            icon: Icons.message,
                            onPressed: () => UrlUtils.openWhatsApp(
                              customerPhone, 
                              "Hello ${appointment.customerName}, I'm calling about your appointment on ${DateFormat('MMM d').format(appointment.startTime)}."
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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<AppointmentProvider>(context, listen: false);

    if (auth.user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text('Appointment Requests'),
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: provider.getTailorAppointmentsStream(auth.user!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const ModernEmptyState(
              icon: Icons.event_busy,
              title: 'No Appointments',
              subtitle: 'New requests will appear here',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (_, i) {
                final a = appointments[i];
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
                              a.customerName,
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

