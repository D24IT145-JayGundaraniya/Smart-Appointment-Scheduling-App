import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/hive_service.dart';

class AppointmentProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  List<Appointment> _appointments = [];

  List<Appointment> get appointments => _appointments;

  void loadAppointments() {
    _appointments = _hiveService.getAllAppointments();
    notifyListeners();
  }

  bool isSlotAvailable(DateTime dateTime) {
    // Basic check: same hour and minute
    return !_appointments.any((a) =>
        a.dateTime.year == dateTime.year &&
        a.dateTime.month == dateTime.month &&
        a.dateTime.day == dateTime.day &&
        a.dateTime.hour == dateTime.hour &&
        a.dateTime.minute == dateTime.minute);
  }

  Future<bool> addAppointment(Appointment appointment) async {
    if (!isSlotAvailable(appointment.dateTime)) {
      return false;
    }
    await _hiveService.addAppointment(appointment);
    loadAppointments();
    return true;
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await _hiveService.updateAppointment(appointment);
    loadAppointments();
  }

  Future<void> deleteAppointment(Appointment appointment) async {
    await _hiveService.deleteAppointment(appointment);
    loadAppointments();
  }

  // Queue Management logic
  List<Appointment> get queue {
    return _appointments
        .where((a) => a.status == 'pending' || a.status == 'confirmed')
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }
}
