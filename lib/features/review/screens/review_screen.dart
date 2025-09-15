import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/services/srs_service.dart';
import 'package:trirecall/features/review/controller/review_controller.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the session provider. This screen will rebuild whenever the
    // current topic changes or the session ends.
    final sessionState = ref.watch(reviewSessionProvider);

    // If the session is finished, show a "Done!" screen.
    if (sessionState == null || sessionState.isFinished) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('All done for now!', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // End the session (clears the state) and go back to the home screen.
                  ref.read(reviewSessionProvider.notifier).endSession();
                  Navigator.of(context).pop();
                },
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final currentTopic = sessionState.currentTopic!;
    final totalTopics = sessionState.topics.length;
    final currentIndex = sessionState.currentIndex + 1;

    return Scaffold(
      appBar: AppBar(
        // Show progress in the app bar.
        title: Text('Reviewing ($currentIndex / $totalTopics)'),
        automaticallyImplyLeading: false, // Hide the default back button.
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Topic Content Area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTopic.title,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text(
                      currentTopic.notes,
                      style: const TextStyle(fontSize: 18, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            
            // Action Buttons Area
            const SizedBox(height: 20),
            _buildReviewButton(
              ref: ref,
              text: 'Revised',
              color: Colors.green,
              action: ReviewAction.revised,
            ),
            const SizedBox(height: 12),
            _buildReviewButton(
              ref: ref,
              text: 'Needs Work',
              color: Colors.orange,
              action: ReviewAction.needsWork,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildReviewButton(
                    ref: ref,
                    text: 'Mastered',
                    color: Colors.blue,
                    action: ReviewAction.mastered,
                    isSmall: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReviewButton(
                    ref: ref,
                    text: 'Reset',
                    color: Colors.red,
                    action: ReviewAction.reset,
                    isSmall: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to reduce code duplication for our buttons.
  Widget _buildReviewButton({
    required WidgetRef ref,
    required String text,
    required Color color,
    required ReviewAction action,
    bool isSmall = false,
  }) {
    return ElevatedButton(
      onPressed: () {
        // When a button is pressed, we call the controller method.
        ref.read(reviewSessionProvider.notifier).reviewCurrentTopic(action);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 16),
        textStyle: TextStyle(
          fontSize: isSmall ? 16 : 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(text),
    );
  }
}