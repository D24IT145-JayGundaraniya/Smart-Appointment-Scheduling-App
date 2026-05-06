import 'package:hive_flutter/hive_flutter.dart';
import '../models/appointment.dart';

class HiveService {
  static const String appointmentBoxName = 'appointments';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AppointmentAdapter());
    
    // CLEARING ALL PREVIOUS DATA FOR NEW APP START
    await Hive.deleteBoxFromDisk(appointmentBoxName);
    
    await Hive.openBox<Appointment>(appointmentBoxName);
  }

  static Box<Appointment> getAppointmentBox() {
    return Hive.box<Appointment>(appointmentBoxName);
  }

  Future<void> addAppointment(Appointment appointment) async {
    final box = getAppointmentBox();
    await box.put(appointment.id, appointment);
  }

  List<Appointment> getAllAppointments() {
    final box = getAppointmentBox();
    return box.values.toList();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await appointment.save();
  }

  Future<void> deleteAppointment(Appointment appointment) async {
    await appointment.delete();
  }
}
