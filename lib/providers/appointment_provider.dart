import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/hive_service.dart';

/// EXAM VIVA - HOW OFFLINE STORAGE WORKS:
/// 1. Hive is a NoSQL database that stores data locally on the device's storage.
/// 2. Data is stored in 'Boxes', which are like tables in a traditional database.
/// 3. Because data is written to the physical disk (and not just RAM), 
///    it remains available even after the app is closed or the device is restarted.

class AppointmentProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  
  // Internal list to provide data to the UI efficiently
  List<Appointment> _appointments = [];
  bool _isSyncing = false;

  // Getters
  List<Appointment> get appointments => _appointments;
  bool get isSyncing => _isSyncing;

  // SIMULATED SYNC LOGIC (For Exam Explanation)
  Future<void> manualSync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    _isSyncing = false;
    notifyListeners();
  }

  void _simulateBackgroundSync() {
    manualSync(); // Trigger the simulation
  }

  // READ: Load data from Hive box into our local list
  void loadAppointments() {
    // We fetch values from Hive and convert to a list
    _appointments = _hiveService.getAllAppointments();
    
    // notifyListeners() tells all widgets to rebuild with the new data
    notifyListeners();
  }

  // CREATE: Save a new appointment to Hive
  Future<bool> addAppointment(Appointment appointment) async {
    if (!isSlotAvailable(appointment.dateTime)) {
      return false;
    }
    
    // 1. Save to physical storage (Hive)
    await _hiveService.addAppointment(appointment);
    
    // 2. Refresh our local list so UI updates
    loadAppointments();
    
    return true;
  }

  // UPDATE: Modify an existing record in Hive
  Future<void> updateAppointment(Appointment appointment) async {
    // 1. Call Hive's save() or put() to write changes to disk
    await _hiveService.updateAppointment(appointment);
    
    // 2. Refresh UI
    loadAppointments();
  }

  // DELETE: Remove record from Hive
  Future<void> deleteAppointment(Appointment appointment) async {
    await _hiveService.deleteAppointment(appointment);
    loadAppointments();
  }

  // Logic to prevent double booking
  bool isSlotAvailable(DateTime dateTime) {
    return !_appointments.any((a) =>
        a.dateTime.year == dateTime.year &&
        a.dateTime.month == dateTime.month &&
        a.dateTime.day == dateTime.day &&
        a.dateTime.hour == dateTime.hour &&
        a.dateTime.minute == dateTime.minute);
  }

  // Active Queue logic (Scheduled or In Progress)
  List<Appointment> get activeQueue {
    return _appointments
        .where((a) => a.status == 'Scheduled' || a.status == 'In Progress')
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Get the person currently being served
  Appointment? get currentServing {
    try {
      return _appointments.firstWhere((a) => a.status == 'In Progress');
    } catch (_) {
      return null;
    }
  }

  // Automated queue movement
  Future<void> moveQueueForward() async {
    try {
      final current = _appointments.firstWhere((a) => a.status == 'In Progress');
      current.status = 'Completed';
      await updateAppointment(current);
    } catch (_) {}

    try {
      final next = activeQueue.firstWhere((a) => a.status == 'Scheduled');
      next.status = 'In Progress';
      await updateAppointment(next);
    } catch (_) {}
  }
}
