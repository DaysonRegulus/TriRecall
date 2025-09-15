import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/features/topics/controller/topic_controller.dart';
import 'package:trirecall/core/services/database_helper.dart';
import 'package:trirecall/features/review/controller/review_controller.dart';

class AllTopicsScreen extends ConsumerWidget {
  const AllTopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the provider that fetches all topics.
    final topicsAsyncValue = ref.watch(allTopicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All My Topics'),
      ),
      // Here, we use the .when() method again to handle the different
      // states of our FutureProvider: loading, error, and data.
      body: topicsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (topics) {
          // If the list is empty, show a helpful message.
          if (topics.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t added any topics yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // If we have data, we build a ListView.
          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];

              // We'll create a simple ListTile to display the topic info.
              // In the future, we can make this a much nicer, custom widget.
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  title: Text(
                    topic.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Due: ${topic.nextDue != null ? topic.nextDue!.toLocal().toString().split(' ')[0] : 'Mastered'}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  // We'll add an onTap later to view topic details.
                  onTap: () async {
                    // --- TEMPORARY TEST LOGIC ---
                    final yesterday = DateTime.now().subtract(const Duration(days: 1));
                    final updatedTopic = topic.copyWith(nextDue: yesterday);
                    await DatabaseHelper.instance.updateTopic(updatedTopic);
                    
                    // Invalidate the providers so the HomeScreen updates
                    ref.invalidate(dueTopicsProvider);
                    ref.invalidate(allTopicsProvider);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${topic.title}" is now due.'))
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}