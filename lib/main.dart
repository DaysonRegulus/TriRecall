import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/theme/theme.dart';
import 'package:trirecall/features/dashboard/screens/home_screen.dart';
import 'package:trirecall/core/services/database_helper.dart'; 

Future<void> main() async {
  // Ensure that Flutter's binding is initialized. This is required for async main.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database.
  await DatabaseHelper.instance.database; 
  
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
      home: const HomeScreen(),
    );
  }
}