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
  String _selectedService = 'Basic Wash'; // Default service
  
  final List<String> _carWashServices = [
    'Basic Wash',
    'Full Detail',
    'Interior Cleaning',
    'Engine Wash',
    'Ceramic Coating',
  ];

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _bookAppointment() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter your name');
      return;
    }

    final dt = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    if (dt.isBefore(DateTime.now())) {
      _showError('Please select a future date and time');
      return;
    }

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.addAppointment(Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      serviceType: _selectedService,
      dateTime: dt,
      queueNumber: provider.appointments.length + 1,
      status: 'Scheduled',
    ));

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wash Booked!'), backgroundColor: Colors.green));
      _nameController.clear();
      setState(() => _selectedService = 'Basic Wash');
    } else {
      _showError('This slot is already reserved!');
    }
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Book a Wash', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Customer Name', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 24),
            const Text('Select Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedService,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.directions_car_filled_outlined),
                labelText: 'Service Type',
              ),
              items: _carWashServices.map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedService = newValue);
                }
              },
            ),
            const SizedBox(height: 32),
            const Text('Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
            const SizedBox(height: 16),
            _PickerTile(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: DateFormat('EEEE, MMM dd').format(_selectedDate),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            _PickerTile(
              icon: Icons.access_time,
              label: 'Time',
              value: _selectedTime.format(context),
              onTap: _pickTime,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Confirm Wash Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
