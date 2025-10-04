// lib/features/review/screens/date_card_review_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trirecall/core/models/date_card_model.dart';
import 'package:trirecall/core/services/srs_service.dart';
import 'package:trirecall/features/review/controller/date_card_review_controller.dart';

class DateCardReviewScreen extends ConsumerStatefulWidget {
  final DateCard dateCard;
  const DateCardReviewScreen({super.key, required this.dateCard});

  @override
  ConsumerState<DateCardReviewScreen> createState() => _DateCardReviewScreenState();
}

class _DateCardReviewScreenState extends ConsumerState<DateCardReviewScreen> {
  final Map<int, ReviewAction> _overrides = {};

  void _onConfirmReview(ReviewAction bulkAction) {
    ref.read(dateCardReviewControllerProvider.notifier).processDateCardReview(
          dateCard: widget.dateCard,
          bulkAction: bulkAction,
          topicOverrides: _overrides,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsyncValue = ref.watch(topicsInDateCardProvider(widget.dateCard.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text('Reviewing: ${DateFormat.yMMMd().format(widget.dateCard.studyDate)}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: topicsAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (topics) {
                if (topics.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No topics logged for this date.\nReview your physical notes, then select an action below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    return ListTile(
                      title: Text(topic.title),
                      trailing: DropdownButton<ReviewAction>(
                        value: _overrides[topic.id],
                        hint: const Text('Default'),
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Default')),
                          DropdownMenuItem(value: ReviewAction.revised, child: Text('Revised')),
                          DropdownMenuItem(value: ReviewAction.needsWork, child: Text('Needs Work')),
                          DropdownMenuItem(value: ReviewAction.mastered, child: Text('Mastered')),
                        ],
                        onChanged: (ReviewAction? newValue) {
                          setState(() {
                            if (newValue == null) {
                              _overrides.remove(topic.id);
                            } else {
                              _overrides[topic.id!] = newValue;
                            }
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // --- BUTTONS ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  'Confirm and mark all non-overridden items as:',
                  textAlign: TextAlign.center,
                  // Best Practice: Use theme colors for text to ensure readability in both light/dark modes.
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                // "Revised" is the primary, positive action. We use a FilledButton.
                FilledButton(
                  onPressed: () => _onConfirmReview(ReviewAction.revised),
                  child: const Text('Revised'),
                ),
                const SizedBox(height: 10),
                // "Needs Work" is a secondary, less positive action. A FilledButton.tonal is perfect.
                FilledButton.tonal(
                  onPressed: () => _onConfirmReview(ReviewAction.needsWork),
                  child: const Text('Needs Work'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}