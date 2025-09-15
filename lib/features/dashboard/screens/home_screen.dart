// lib/features/dashboard/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/features/review/controller/review_controller.dart';
import 'package:trirecall/features/review/screens/review_screen.dart';
import 'package:trirecall/features/topics/screens/add_topic_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueTopicsAsyncValue = ref.watch(dueTopicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Revision'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddTopicScreen(),
          ));
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Topic',
      ),
      body: dueTopicsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (dueTopics) {
          if (dueTopics.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'All caught up! No topics due today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Icon(Icons.school, size: 80, color: Colors.white70),
                const SizedBox(height: 20),
                Text(
                  '${dueTopics.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Topic${dueTopics.length == 1 ? '' : 's'} due for review',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    ref.read(reviewSessionProvider.notifier).startSession(dueTopics);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ReviewScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Start Review'),
                ),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }
}