import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          Consumer<AppointmentProvider>(
            builder: (context, provider, child) {
              if (provider.isSyncing) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.sync),
                onPressed: () => provider.manualSync(),
                tooltip: 'Sync with Cloud',
              );
            },
          ),
          TextButton.icon(
            onPressed: () => Provider.of<AppointmentProvider>(context, listen: false).moveQueueForward(),
            icon: const Icon(Icons.skip_next, color: Colors.white),
            label: const Text('Next Token', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          final appointments = provider.appointments;

          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final dateStr = DateFormat('MMM dd, hh:mm a').format(appointment.dateTime);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(appointment.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${appointment.serviceType} • $dateStr'),
                        trailing: Chip(
                          label: Text(appointment.status, style: const TextStyle(fontSize: 12)),
                          backgroundColor: _getStatusColor(appointment.status),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (appointment.status == 'Scheduled')
                            _ActionButton(
                              icon: Icons.play_arrow,
                              label: 'Start',
                              color: Colors.orange,
                              onTap: () => _updateStatus(context, appointment, 'In Progress'),
                            ),
                          if (appointment.status != 'Cancelled' && appointment.status != 'Completed') ...[
                            _ActionButton(
                              icon: Icons.edit_calendar,
                              label: 'Reschedule',
                              color: Colors.blue,
                              onTap: () => _reschedule(context, appointment),
                            ),
                            _ActionButton(
                              icon: Icons.cancel_outlined,
                              label: 'Cancel',
                              color: Colors.red,
                              onTap: () => _updateStatus(context, appointment, 'Cancelled'),
                            ),
                          ],
                          if (appointment.status == 'In Progress')
                             _ActionButton(
                              icon: Icons.check_circle,
                              label: 'Complete',
                              color: Colors.green,
                              onTap: () => _updateStatus(context, appointment, 'Completed'),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateStatus(BuildContext context, Appointment appointment, String newStatus) async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    appointment.status = newStatus;
    await provider.updateAppointment(appointment);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
    }
  }

  Future<void> _reschedule(BuildContext context, Appointment appointment) async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final date = await showDatePicker(
      context: context,
      initialDate: appointment.dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(appointment.dateTime),
      );

      if (time != null) {
        appointment.dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        await provider.updateAppointment(appointment);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment Rescheduled')));
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled': return Colors.blue.shade100;
      case 'In Progress': return Colors.orange.shade100;
      case 'Completed': return Colors.green.shade100;
      case 'Cancelled': return Colors.red.shade100;
      default: return Colors.grey.shade100;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
