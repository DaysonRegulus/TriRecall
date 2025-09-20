import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trirecall/features/settings/controller/schedule_controller.dart';

class ScheduleSettingsScreen extends ConsumerStatefulWidget {
  const ScheduleSettingsScreen({super.key});
  @override
  ConsumerState<ScheduleSettingsScreen> createState() => _ScheduleSettingsScreenState();
}

class _ScheduleSettingsScreenState extends ConsumerState<ScheduleSettingsScreen> {
  // Local UI state that we will use to save.
  DateTime? _selectedDate;
  Set<int> _selectedDays = {1, 2, 3, 4, 5, 6}; // Default Mon-Sat

  @override
  void initState() {
    super.initState();
    // Load the saved settings when the screen first opens.
    ref.read(scheduleControllerProvider.notifier).loadSettings();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onDaySelected(bool? isSelected, int day) {
    setState(() {
      if (isSelected == true) {
        _selectedDays.add(day);
      } else {
        _selectedDays.remove(day);
      }
    });
  }

  void _onSave() async { // Make the method async
    if (_selectedDate != null) {
      final newSettings = ScheduleSettingsState(
        startDate: _selectedDate,
        studyDays: _selectedDays,
      );
      
      // We now await the save operation to complete.
      await ref.read(scheduleControllerProvider.notifier)
          .saveSettingsAndGenerateDateCards(newSettings);

      // CRITICAL SAFETY CHECK: After the await, check if the widget
      // is still on screen before using `context`.
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule saved and Date Cards generated!')),
      );
      Navigator.of(context).pop();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the provider to get the initial loaded state.
    ref.listen<ScheduleSettingsState?>(scheduleControllerProvider, (previous, next) {
      if (next != null) {
        setState(() {
          _selectedDate = next.startDate;
          _selectedDays = next.studyDays;
        });
      }
    });

    final scheduleState = ref.watch(scheduleControllerProvider);
    final Map<String, int> daysOfWeek = {
      'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7
    };

    if (scheduleState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Study Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('When did you start studying?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              children: [
                ActionChip(
                  label: Text(
                    _selectedDate != null ? DateFormat.yMMMd().format(_selectedDate!) : 'Select a Date',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _pickDate(context),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Which days do you study?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: daysOfWeek.entries.map((entry) {
                return FilterChip(
                  label: Text(entry.key),
                  selected: _selectedDays.contains(entry.value),
                  onSelected: (isSelected) => _onDaySelected(isSelected, entry.value),
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _onSave,
              child: const Text('Save Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}