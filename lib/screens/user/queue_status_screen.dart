import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Wash Queue', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          final queue = provider.activeQueue;
          final current = provider.currentServing;

          if (queue.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No cars in queue right now', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildServingCard(context, current),
              const SizedBox(height: 32),
              const Text('In Line', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 16),
              ...queue.skip(current != null ? 1 : 0).indexed.map((item) {
                final index = item.$1;
                final appt = item.$2;
                return _QueueItem(appointment: appt, position: index + 1);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildServingCard(BuildContext context, dynamic current) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CURRENTLY WASHING', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(current?.name ?? 'Ready...', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(current?.serviceType ?? 'Ready for next vehicle', style: const TextStyle(color: Colors.white60, fontSize: 16)),
          const Divider(height: 40, color: Colors.white24),
          Row(
            children: [
              _InfoBadge(label: 'Token', value: '#${current?.queueNumber ?? '--'}'),
              const SizedBox(width: 24),
              const _InfoBadge(label: 'Est. Time', value: '15 min'),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  final dynamic appointment;
  final int position;

  const _QueueItem({required this.appointment, required this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('#${appointment.queueNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(appointment.serviceType, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Pos: $position', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('~${position * 15} min', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
