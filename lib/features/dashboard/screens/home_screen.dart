import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trirecall/core/models/due_item_model.dart';
import 'package:trirecall/core/utils/color_utils.dart';
import 'package:trirecall/features/review/controller/due_items_controller.dart';
import 'package:trirecall/features/topics/screens/add_topic_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch our new provider for the mixed list.
    final dueItemsAsyncValue = ref.watch(dueItemsProvider);

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

          // The ListView.builder is perfect for our dynamic list.
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: dueItems.length,
            itemBuilder: (context, index) {
              final item = dueItems[index];
              // Here we use the type-safe wrapper to decide which widget to build.
              if (item is DueDateCardItem) {
                return _DateCardListItem(dateCardItem: item);
              } else if (item is DueTopicItem) {
                return _TopicListItem(topicItem: item);
              }
              return const SizedBox.shrink(); // Should never happen
            },
          );
        },
      ),
    );
  }
}

// A private widget to render a DateCard item.
class _DateCardListItem extends ConsumerWidget {
  final DueDateCardItem dateCardItem;
  const _DateCardListItem({required this.dateCardItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateCard = dateCardItem.dateCard;
    return Card(
      clipBehavior: Clip.antiAlias, // Ensures the border respects the shape
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.calendar_today)),
        title: const Text('Review Study Day', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat.yMMMd().format(dateCard.studyDate)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO in Step 16: Navigate to DateCardReviewScreen
          print('Tapped on DateCard for ${dateCard.studyDate}');
        },
      ),
    );
  }
}

// A private widget to render a "Stray Topic" item.
class _TopicListItem extends ConsumerWidget {
  final DueTopicItem topicItem;
  const _TopicListItem({required this.topicItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topic = topicItem.topic;
    return Card(
      // Make it visually distinct with a colored border.
      shape: RoundedRectangleBorder(
        side: BorderSide(color: hexToColor('#A133FF'), width: 1.5), // A purple accent
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.lightbulb_outline)),
        title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('From: ${DateFormat.yMMMd().format(topic.studiedOn)}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO in Step 16: Navigate to a single topic review
          print('Tapped on Topic: ${topic.title}');
        },
      ),
    );
  }
}