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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Name or ID...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = ''))
                  : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Date Filter
                FilterChip(
                  label: Text(_selectedDate == null ? 'Date' : DateFormat('MMM dd').format(_selectedDate!)),
                  selected: _selectedDate != null,
                  onSelected: (_) async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    setState(() => _selectedDate = date);
                  },
                ),
                const SizedBox(width: 8),

                // Status Filter
                DropdownButton<String>(
                  hint: const Text('Status'),
                  value: _selectedStatus,
                  items: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedStatus = val),
                ),
                const SizedBox(width: 8),

                // Clear Filters
                if (_searchQuery.isNotEmpty || _selectedStatus != null || _selectedDate != null)
                  TextButton(
                    onPressed: () => setState(() {
                      _searchQuery = '';
                      _selectedStatus = null;
                      _selectedDate = null;
                    }),
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),

          const Divider(),

          // Results List
          Expanded(
            child: Consumer<AppointmentProvider>(
              builder: (context, provider, child) {
                final results = provider.appointments.where((a) {
                  final matchesSearch = a.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                        a.id.contains(_searchQuery);
                  final matchesStatus = _selectedStatus == null || a.status == _selectedStatus;
                  final matchesDate = _selectedDate == null || 
                                     (a.dateTime.year == _selectedDate!.year && 
                                      a.dateTime.month == _selectedDate!.month && 
                                      a.dateTime.day == _selectedDate!.day);
                  
                  return matchesSearch && matchesStatus && matchesDate;
                }).toList();

                if (results.isEmpty) {
                  return const Center(child: Text('No matching appointments found.'));
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final appointment = results[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(appointment.queueNumber.toString())),
                      title: Text(appointment.name),
                      subtitle: Text('${appointment.serviceType} • ${appointment.status}'),
                      trailing: Text(DateFormat('MMM dd').format(appointment.dateTime)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
