import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/features/settings/controller/settings_controller.dart';
import 'package:trirecall/features/settings/screens/schedule_settings_screen.dart'; 

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Study Schedule'),
              subtitle: const Text('Set your start date and weekly study days.'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ScheduleSettingsScreen(),
                ));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.download_for_offline),
              title: const Text('Export Data'),
              subtitle: const Text('Save a backup copy of your database.'),
              onTap: () {
                // Call the controller method.
                ref.read(settingsControllerProvider.notifier).exportDatabase(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Import Data'),
              subtitle: const Text('Restore data from a backup file. This will overwrite all current data.'),
              onTap: () {
                // Call the controller method.
                ref.read(settingsControllerProvider.notifier).importDatabase(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }
}