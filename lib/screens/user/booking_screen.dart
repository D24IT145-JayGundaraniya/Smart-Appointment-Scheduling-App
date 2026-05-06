import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _nameController = TextEditingController();
  final _serviceController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _bookAppointment() async {
    final name = _nameController.text.trim();
    final service = _serviceController.text.trim();

    // 1. Validate Empty Fields
    if (name.isEmpty || service.isEmpty) {
      _showError('Name and Service Type are required');
      return;
    }

    final appointmentDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // 2. Validate Future Date
    if (appointmentDateTime.isBefore(DateTime.now())) {
      _showError('Please select a future date and time');
      return;
    }

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    
    final newAppointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      serviceType: service,
      dateTime: appointmentDateTime,
      queueNumber: provider.appointments.length + 1,
      status: 'Scheduled',
    );

    // 3. Prevent Duplicate Bookings (Logic inside Provider)
    final success = await provider.addAppointment(newAppointment);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment Booked Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _nameController.clear();
      _serviceController.clear();
    } else {
      _showError('This slot is already booked by someone else!');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _serviceController,
              decoration: const InputDecoration(labelText: 'Service Type'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                  ),
                ),
                TextButton(onPressed: _pickDate, child: const Text('Select Date')),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Time: ${_selectedTime.format(context)}',
                  ),
                ),
                TextButton(onPressed: _pickTime, child: const Text('Select Time')),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
