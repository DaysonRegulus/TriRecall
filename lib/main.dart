import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/theme/theme.dart';
import 'package:trirecall/core/services/database_helper.dart';
import 'package:trirecall/core/services/data_maintenance_service.dart';
import 'package:trirecall/features/dashboard/screens/nav_hub_screen.dart'; 

Future<void> main() async {
  // Ensure that Flutter's binding is initialized. This is required for async main.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database.
  await DatabaseHelper.instance.database; 

  // Run the decay check in the background. We don't need to `await` it,
  // as the app can continue to load while this happens.
  DataMaintenanceService().applyDecay();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TriRecall',
      theme: AppTheme.darkThemeMode,
      // We will temporarily use HomeScreen as our entry point.
      home: const NavHubScreen(),
    );
  }
}