import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/features/review/controller/review_controller.dart';
import 'package:trirecall/features/topics/screens/add_topic_screen.dart';
import 'package:trirecall/features/review/screens/review_screen.dart';

// We now make it a ConsumerWidget to access Riverpod.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider that fetches our due topics for today.
    final dueTopicsAsyncValue = ref.watch(dueTopicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Revision'),
        // We can add actions later, like viewing all topics or subjects.
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
          // If there are no topics due, show a welcoming message.
          if (dueTopics.isEmpty) {
            return const Center(
              child: Text(
                'All caught up! No topics due today.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // If topics are due, show a summary card and a "Start Review" button.
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
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Topic${dueTopics.length == 1 ? '' : 's'} due for review',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // 1. Start the session using the list of due topics.
                    ref.read(reviewSessionProvider.notifier).startSession(dueTopics);
                    
                    // 2. Navigate to the ReviewScreen.
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ReviewScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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