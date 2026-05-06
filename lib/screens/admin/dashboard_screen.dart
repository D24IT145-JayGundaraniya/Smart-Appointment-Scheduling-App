import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Consumer<AppointmentProvider>(
            builder: (context, provider, child) {
              return provider.isSyncing 
                ? const Padding(padding: EdgeInsets.only(right: 16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                : IconButton(icon: const Icon(Icons.sync_rounded), onPressed: provider.manualSync);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          final appointments = provider.appointments;

          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments found', style: TextStyle(color: Colors.grey)));
          }

          return Column(
            children: [
              _buildStatsHeader(context, provider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) => _AdminAppointmentCard(appointment: appointments[index]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Provider.of<AppointmentProvider>(context, listen: false).moveQueueForward(),
        label: const Text('Next Token'),
        icon: const Icon(Icons.skip_next_rounded),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, AppointmentProvider provider) {
    final active = provider.activeQueue.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          _StatItem(label: 'Active', value: active.toString(), color: Colors.blue),
          const SizedBox(width: 12),
          _StatItem(label: 'Completed', value: provider.appointments.where((a) => a.status == 'Completed').length.toString(), color: Colors.green),
          const SizedBox(width: 12),
          _StatItem(label: 'Cancelled', value: provider.appointments.where((a) => a.status == 'Cancelled').length.toString(), color: Colors.red),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AdminAppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AdminAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(appointment.dateTime);
    final dateStr = DateFormat('MMM dd').format(appointment.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(appointment.status).withOpacity(0.1),
              child: Text('#${appointment.queueNumber}', style: TextStyle(color: _getStatusColor(appointment.status), fontWeight: FontWeight.bold)),
            ),
            title: Text(appointment.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${appointment.serviceType} • $dateStr, $timeStr'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(appointment.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                appointment.status,
                style: TextStyle(color: _getStatusColor(appointment.status), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (appointment.status != 'Completed' && appointment.status != 'Cancelled')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  if (appointment.status == 'Scheduled')
                    Expanded(
                      child: _ActionBtn(
                        label: 'Start',
                        icon: Icons.play_arrow_rounded,
                        color: Colors.orange,
                        onTap: () => _update(context, 'In Progress'),
                      ),
                    ),
                  if (appointment.status == 'In Progress')
                    Expanded(
                      child: _ActionBtn(
                        label: 'Complete',
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                        onTap: () => _update(context, 'Completed'),
                      ),
                    ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    label: 'Cancel',
                    icon: Icons.close_rounded,
                    color: Colors.red,
                    onTap: () => _update(context, 'Cancelled'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _update(BuildContext context, String status) {
    appointment.status = status;
    Provider.of<AppointmentProvider>(context, listen: false).updateAppointment(appointment);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled': return Colors.blue;
      case 'In Progress': return Colors.orange;
      case 'Completed': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
