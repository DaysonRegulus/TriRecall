import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      title: 'TriRecall',
      // For now, we just show a simple "It works!" message.
      // This confirms our entire setup is correct.
      home: Scaffold(
        body: Center(
          child: Text('TriRecall: Foundation is Set!'),
        ),
      ),
    );
  }
}