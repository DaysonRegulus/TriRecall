import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/features/topics/controller/topic_controller.dart';

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
              return Dismissible(
                // The key is essential. It lets Flutter know which specific item
                // in the list is being dismissed.
                key: ValueKey(topic.id),
                
                // This is the background that shows up as you swipe.
                background: Container(
                  color: Colors.red.shade800,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                
                // We only want to allow swiping from right to left.
                direction: DismissDirection.endToStart,

                // This powerful callback runs BEFORE the item is dismissed.
                // It allows us to show a confirmation dialog.
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: Text('Are you sure you want to delete "${topic.title}"? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false), // Returns false
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true), // Returns true
                          child: const Text('Delete'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                      ],
                    ),
                  );
                },

                // This callback runs only AFTER confirmDismiss returns true.
                // This is where we call our deletion logic.
                onDismissed: (direction) {
                  ref.read(topicControllerProvider.notifier).deleteTopic(
                        topicId: topic.id!,
                        ref: ref,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${topic.title}" was deleted.')),
                  );
                },

                // The actual widget to display.
                child: Card(
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
                    // The onTap is now empty, ready for a future "Topic Details" screen.
                    onTap: () {
                      print('Tapped on topic: ${topic.title}');
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}