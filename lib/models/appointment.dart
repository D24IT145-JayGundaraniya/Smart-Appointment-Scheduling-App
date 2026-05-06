import 'package:hive/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 0)
class Appointment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  String status; // Scheduled, In Progress, Completed, Cancelled

  @HiveField(4)
  final String serviceType;

  @HiveField(5)
  final int queueNumber;

  @HiveField(6)
  bool isSynced; // Flag to track if data is synced with a server

  Appointment({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.status,
    required this.serviceType,
    required this.queueNumber,
    this.isSynced = false, // Default: local data is not synced
  });
}
