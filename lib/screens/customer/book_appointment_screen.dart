import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/tailor_model.dart';

class BookAppointmentScreen extends StatefulWidget {
  final TailorModel tailor;
  const BookAppointmentScreen({super.key, required this.tailor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    if (auth.user == null) return;

    if (_date == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    final start = DateTime(_date!.year, _date!.month, _date!.day, _startTime!.hour, _startTime!.minute);
    final end = DateTime(_date!.year, _date!.month, _date!.day, _endTime!.hour, _endTime!.minute);
    if (!end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final appointment = AppointmentModel(
      id: '',
      customerId: auth.user!.id,
      customerName: auth.user!.name,
      tailorId: widget.tailor.id,
      tailorName: widget.tailor.businessName ?? widget.tailor.name,
      startTime: start,
      endTime: end,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final ok = await provider.bookAppointment(appointment);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment request sent')), 
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to book appointment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: Text(widget.tailor.businessName ?? widget.tailor.name),
                subtitle: Text(widget.tailor.name),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(_date == null ? 'Choose date' : '${_date!.day}/${_date!.month}/${_date!.year}'),
            ),
            const SizedBox(height: 16),
            const Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickStart,
              icon: const Icon(Icons.access_time),
              label: Text(_startTime == null ? 'Choose start time' : _startTime!.format(context)),
            ),
            const SizedBox(height: 16),
            const Text('End Time', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickEnd,
              icon: const Icon(Icons.access_time_filled),
              label: Text(_endTime == null ? 'Choose end time' : _endTime!.format(context)),
            ),
            const SizedBox(height: 16),
            const Text('Notes (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Anything specific for this appointment...',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : _submit,
                child: provider.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}












