import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  String? _selectedStatus;
  DateTime? _selectedDate;
  String? _selectedService;

  final List<String> _carWashServices = [
    'Basic Wash',
    'Full Detail',
    'Interior Cleaning',
    'Engine Wash',
    'Ceramic Coating',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Wash Directory', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          _buildSearchBox(),
          _buildFilterChips(),
          const SizedBox(height: 16),
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search customer name...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterTag(
            label: _selectedDate == null ? 'All Dates' : DateFormat('MMM dd').format(_selectedDate!),
            icon: Icons.calendar_today_rounded,
            isSelected: _selectedDate != null,
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              setState(() => _selectedDate = d);
            },
          ),
          const SizedBox(width: 8),
          _FilterTag(
            label: _selectedService ?? 'All Services',
            icon: Icons.directions_car_filled_outlined,
            isSelected: _selectedService != null,
            onTap: _showServicePicker,
          ),
          const SizedBox(width: 8),
          _FilterTag(
            label: _selectedStatus ?? 'All Status',
            icon: Icons.flag_rounded,
            isSelected: _selectedStatus != null,
            onTap: _showStatusPicker,
          ),
          if (_searchQuery.isNotEmpty || _selectedStatus != null || _selectedDate != null || _selectedService != null)
             Padding(
               padding: const EdgeInsets.only(left: 8),
               child: IconButton(
                 onPressed: () => setState(() { _searchQuery = ''; _selectedStatus = null; _selectedDate = null; _selectedService = null; }),
                 icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.grey),
               ),
             ),
        ],
      ),
    );
  }

  void _showStatusPicker() {
    _showPicker('Filter by Status', ['Scheduled', 'In Progress', 'Completed', 'Cancelled'], _selectedStatus, (val) {
      setState(() => _selectedStatus = val);
    });
  }

  void _showServicePicker() {
    _showPicker('Filter by Service', _carWashServices, _selectedService, (val) {
      setState(() => _selectedService = val);
    });
  }

  void _showPicker(String title, List<String> options, String? currentVal, Function(String?) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: options.map((s) => ChoiceChip(
                label: Text(s),
                selected: currentVal == s,
                onSelected: (sel) {
                  onSelected(sel ? s : null);
                  Navigator.pop(context);
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        final results = provider.appointments.where((a) {
          final matchesSearch = a.name.toLowerCase().contains(_searchQuery.toLowerCase()) || a.id.contains(_searchQuery);
          final matchesStatus = _selectedStatus == null || a.status == _selectedStatus;
          final matchesService = _selectedService == null || a.serviceType == _selectedService;
          final matchesDate = _selectedDate == null || (a.dateTime.year == _selectedDate!.year && a.dateTime.month == _selectedDate!.month && a.dateTime.day == _selectedDate!.day);
          return matchesSearch && matchesStatus && matchesDate && matchesService;
        }).toList();

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade200),
                const SizedBox(height: 16),
                const Text('No bookings match your filters', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final appt = results[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(backgroundColor: Colors.indigo.shade50, child: Text(appt.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                title: Text(appt.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text('${appt.serviceType} • ${appt.status}', style: const TextStyle(fontSize: 12)),
                trailing: Text(DateFormat('MMM dd').format(appt.dateTime), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTag({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade600;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
