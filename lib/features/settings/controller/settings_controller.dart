import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trirecall/core/services/database_helper.dart';
import 'package:trirecall/core/utils/show_snackbar.dart';

final settingsControllerProvider =
    StateNotifierProvider.autoDispose<SettingsController, bool>((ref) {
  return SettingsController();
});

class SettingsController extends StateNotifier<bool> {
  SettingsController() : super(false);

  Future<void> exportDatabase(BuildContext context) async {
    // Safety Check: If the widget is no longer on screen, do nothing.
    if (!context.mounted) return;
    state = true;

    try {
      final status = await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        final dbPath = await getDatabasesPath();
        final sourcePath = join(dbPath, 'trirecall.db');
        final sourceFile = File(sourcePath);

        if (!await sourceFile.exists()) {
          if (!context.mounted) return;
          showSnackBar(context, 'Database file not found.', isError: true);
          return;
        }

        // 1. Ask the user to pick a DIRECTORY.
        final String? outputDirectory =
            await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Please select a folder to save the backup:',
        );

        if (outputDirectory != null) {
          // 2. Construct the full destination path ourselves.
          final fileName = 'trirecall_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.db';
          final destinationPath = join(outputDirectory, fileName);
          
          // 3. Copy the file.
          await sourceFile.copy(destinationPath);
          
          if (!context.mounted) return;
          showSnackBar(context, 'Data exported successfully!');
        } else {
          if (!context.mounted) return;
          showSnackBar(context, 'Export canceled.');
        }
      } else if (status.isPermanentlyDenied) {
        if (!context.mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Storage permission is permanently denied. Please enable it in app settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        if (!context.mounted) return;
        showSnackBar(context, 'Storage permission is required to export data.',
            isError: true);
      }
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, 'An error occurred during export: $e', isError: true);
    } finally {
      // The `mounted` check on the StateNotifier itself is a good safety net.
      if (mounted) {
        state = false;
      }
    }
  }

  Future<void> importDatabase(BuildContext context, WidgetRef ref) async {
    // Add the same safety checks to the import method.
    if (!context.mounted) return;
    state = true;
    try {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        if (!context.mounted) return;
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Database'),
            content: const Text(
                'Importing a backup will overwrite your current data. Are you sure you want to continue?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Import'),
              ),
            ],
          ),
        );

        if (confirmed != true) {
          if (!context.mounted) return;
          showSnackBar(context, 'Import canceled.');
          if (mounted) state = false;
          return;
        }

        final result = await FilePicker.platform.pickFiles(type: FileType.any);

        if (result != null && result.files.single.path != null) {
          final sourceFile = File(result.files.single.path!);
          final dbPath = await getDatabasesPath();
          final destinationPath = join(dbPath, 'trirecall.db');
          
          await DatabaseHelper.instance.close();
          await sourceFile.copy(destinationPath);
          
          showSnackBar(context, 'Import successful! Please restart the app to see your restored data.');
        } else {
          if (!context.mounted) return;
          showSnackBar(context, 'No file selected.');
        }
      } else if (status.isPermanentlyDenied) {
        if (!context.mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Storage permission is permanently denied. Please enable it in app settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        if (!context.mounted) return;
        showSnackBar(context, 'Storage permission is required to import data.',
            isError: true);
      }
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, 'An error occurred during import: $e', isError: true);
    } finally {
      if (mounted) {
        state = false;
      }
    }
  }
}