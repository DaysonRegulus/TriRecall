// lib/features/dashboard/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trirecall/core/models/due_item_model.dart';
import 'package:trirecall/features/review/controller/due_items_controller.dart';
import 'package:trirecall/features/topics/screens/add_topic_screen.dart';
import 'package:trirecall/features/review/screens/date_card_review_screen.dart';
import 'package:trirecall/features/review/screens/review_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueItemsAsyncValue = ref.watch(dueItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Revision'),
      ),
      // M3 Update: The default FAB is now a "squircle".
      // We can use a branded FAB style for more emphasis.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddTopicScreen(),
          ));
        },
        label: const Text('Add Topic'),
        icon: const Icon(Icons.add),
        tooltip: 'Add New Topic',
      ),
      body: dueItemsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (dueItems) {
          if (dueItems.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'All caught up! No items due for review today.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: dueItems.length,
            itemBuilder: (context, index) {
              final item = dueItems[index];
              if (item is DueDateCardItem) {
                return _DateCardListItem(dateCardItem: item);
              } else if (item is DueTopicItem) {
                return _TopicListItem(topicItem: item);
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

class _DateCardListItem extends ConsumerWidget {
  final DueDateCardItem dateCardItem;
  const _DateCardListItem({required this.dateCardItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateCard = dateCardItem.dateCard;

    // We use a Filled Card for incomplete items to draw attention.
    if (dateCard.isIncomplete) {
      return Card.filled(
        // Best Practice: Use semantic colors from the theme.
        // `tertiaryContainer` is designed for exactly this kind of attention-grabbing accent.
        // It will be a soft, harmonious color derived from our seed.
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: ListTile(
          leading: Icon(
            Icons.warning_amber_rounded,
            // And we use the corresponding `onTertiaryContainer` for the icon color.
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
          title: Text(
            'Finish Logging Study Day',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
          subtitle: Text(
            DateFormat.yMMMd().format(dateCard.studyDate),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiaryContainer.withOpacity(0.8),
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.onTertiaryContainer),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DateCardReviewScreen(dateCard: dateCard),
              ),
            );
          },
        ),
      );
    }

    // Standard, elevated card for regular due items.
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.calendar_today)),
        title: const Text('Review Study Day', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat.yMMMd().format(dateCard.studyDate)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DateCardReviewScreen(dateCard: dateCard),
            ),
          );
        },
      ),
    );
  }
}

class _TopicListItem extends ConsumerWidget {
  final DueTopicItem topicItem;
  const _TopicListItem({required this.topicItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topic = topicItem.topic;

    return Card.outlined(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.lightbulb_outline)),
        title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('From: ${DateFormat.yMMMd().format(topic.studiedOn)}'),
        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: () {
          // The ReviewScreen expects a List of topics to create a session.
          // Since this is a single stray topic, we simply pass a list
          // containing only this one topic.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReviewScreen(dueTopics: [topic]),
            ),
          );
        },
      ),
    );
  }
}