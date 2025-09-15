import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trirecall/core/theme/theme.dart';
import 'package:trirecall/features/auth/screens/splash_screen.dart';

Future<void> main() async {
  // Ensure that Flutter bindings are initialized before any async operations.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env file.
  await dotenv.load(fileName: ".env");

  // Initialize the Supabase client.
  // We use the '!' operator to assert that these values are not null,
  // as our app cannot function without them.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // Run the app, wrapped in a ProviderScope for Riverpod state management.
  runApp(const ProviderScope(child: MyApp()));
}

// Helper to easily access the Supabase client throughout the app.
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // This line removes the "Debug" banner from the top right corner.
      debugShowCheckedModeBanner: false, 
      title: 'TriRecall',
      // This line applies our custom dark theme to the entire app.
      theme: AppTheme.darkThemeMode, 
      // This sets our new SplashScreen as the first screen to be displayed.
      home: const SplashScreen(),
    );
  }
}