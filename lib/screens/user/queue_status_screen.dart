import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Queue Status')),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          final queue = provider.activeQueue;
          final current = provider.currentServing;

          if (queue.isEmpty) {
            return const Center(child: Text('No active queue at the moment.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Serving Card
                Card(
                  color: Colors.indigo.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('NOW SERVING',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo)),
                            Text(current?.name ?? '---',
                                style: const TextStyle(fontSize: 24)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '#${current?.queueNumber ?? '--'}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Upcoming Queue',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final appointment = queue[index];
                      final position = index + 1;
                      final waitTime = index * 10;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('#${appointment.queueNumber}'),
                          ),
                          title: Text(appointment.name),
                          subtitle: Text('Status: ${appointment.status}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Pos: $position',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text('~$waitTime min',
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
