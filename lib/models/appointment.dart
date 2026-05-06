import 'package:hive/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 0)
class Appointment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String serviceType;

  @HiveField(3)
  final DateTime dateTime;

  @HiveField(4)
  final int queueNumber;

  @HiveField(5)
  final String status; // Scheduled, In Progress, Completed, Cancelled

  Appointment({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.dateTime,
    required this.queueNumber,
    required this.status,
  });
}
