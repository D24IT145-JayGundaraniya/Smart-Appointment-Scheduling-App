import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          final appointments = provider.appointments;
          
          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments yet.'));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return ListTile(
                title: Text(appointment.name),
                subtitle: Text('${appointment.serviceType} - ${appointment.status} (Queue: ${appointment.queueNumber})'),
                trailing: Text(appointment.dateTime.toString().split(' ')[0]),
              );
            },
          );
        },
      ),
    );
  }
}
