import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/subject_model.dart';
import 'package:trirecall/features/topics/controller/topic_controller.dart';
import 'package:trirecall/features/topics/enums/topic_sort_filter.dart';

class SubjectTopicsScreen extends ConsumerStatefulWidget {
  // It requires a Subject object to know what to display.
  final Subject subject;
  const SubjectTopicsScreen({super.key, required this.subject});

  @override
  ConsumerState<SubjectTopicsScreen> createState() => _SubjectTopicsScreenState();
}

class _SubjectTopicsScreenState extends ConsumerState<SubjectTopicsScreen> {
  // Local state for our UI controls.
  TopicSortOption _sortOption = TopicSortOption.mostRecent;
  TopicFilterOption _filterOption = TopicFilterOption.all;

  @override
  Widget build(BuildContext context) {
    // We watch our new .family provider, passing in the subject's ID.
    // The '!' is safe because a subject coming from the database will always have an ID.
    final topicsAsyncValue = ref.watch(topicsForSubjectProvider(widget.subject.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.title),
      ),
      body: topicsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allTopics) {
          // --- FILTERING AND SORTING LOGIC ---
          // This logic runs every time the state changes, ensuring the list is always correct.
          var displayedTopics = allTopics.where((topic) {
            switch (_filterOption) {
              case TopicFilterOption.active:
                return topic.status == 'active';
              case TopicFilterOption.mastered:
                return topic.status == 'mastered';
              case TopicFilterOption.all:
              default:
                return true;
            }
          }).toList();

          displayedTopics.sort((a, b) {
            switch (_sortOption) {
              case TopicSortOption.oldest:
                return a.createdAt.compareTo(b.createdAt);
              case TopicSortOption.dueSoonest:
                // Handle null due dates for mastered items.
                if (a.nextDue == null) return 1;
                if (b.nextDue == null) return -1;
                return a.nextDue!.compareTo(b.nextDue!);
              case TopicSortOption.mostRecent:
              default:
                return b.createdAt.compareTo(a.createdAt);
            }
          });
          // --- END OF LOGIC ---

          return Column(
            children: [
              // --- UI FOR CONTROLS ---
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // A dropdown for sorting options.
                    DropdownButton<TopicSortOption>(
                      value: _sortOption,
                      onChanged: (value) => setState(() => _sortOption = value!),
                      items: const [
                        DropdownMenuItem(value: TopicSortOption.mostRecent, child: Text('Newest')),
                        DropdownMenuItem(value: TopicSortOption.oldest, child: Text('Oldest')),
                        DropdownMenuItem(value: TopicSortOption.dueSoonest, child: Text('Due Soonest')),
                      ],
                    ),
                    // A dropdown for filtering options.
                    DropdownButton<TopicFilterOption>(
                      value: _filterOption,
                      onChanged: (value) => setState(() => _filterOption = value!),
                      items: const [
                        DropdownMenuItem(value: TopicFilterOption.all, child: Text('All')),
                        DropdownMenuItem(value: TopicFilterOption.active, child: Text('Active')),
                        DropdownMenuItem(value: TopicFilterOption.mastered, child: Text('Mastered')),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // --- UI FOR TOPIC LIST ---
              Expanded(
                child: displayedTopics.isEmpty
                    ? const Center(child: Text('No topics match your criteria.'))
                    : ListView.builder(
                        itemCount: displayedTopics.length,
                        itemBuilder: (context, index) {
                          final topic = displayedTopics[index];
                          return Dismissible(
                            key: ValueKey(topic.id),
                            background: Container(
                              // Use the theme's error color for a consistent "destructive" signal.
                              color: Theme.of(context).colorScheme.errorContainer,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              // Use the corresponding "on" color for the icon.
                              child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: Text('Are you sure you want to delete "${topic.title}"? This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              ref.read(topicControllerProvider.notifier).deleteTopic(
                                    topicId: topic.id!,
                                    ref: ref,
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('"${topic.title}" was deleted.')),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              child: ListTile(
                                title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  'Status: ${topic.status} | Due: ${topic.nextDue != null ? topic.nextDue!.toLocal().toString().split(' ')[0] : 'N/A'}'
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}