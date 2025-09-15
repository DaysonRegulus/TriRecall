import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/topic_model.dart'; // Import the Topic model
import 'package:trirecall/core/services/srs_service.dart';
import 'package:trirecall/features/review/controller/review_controller.dart';

// Change to a ConsumerStatefulWidget
class ReviewScreen extends ConsumerStatefulWidget {
  // Add a constructor that requires the list of topics.
  final List<Topic> dueTopics;
  const ReviewScreen({super.key, required this.dueTopics});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  void initState() {
    super.initState();
    // This is the key to the fix. We use a special callback to ensure this
    // runs after the initial build but before the user sees the screen.
    // It safely starts the session with the data passed from the HomeScreen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewSessionProvider.notifier).startSession(widget.dueTopics);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(reviewSessionProvider);

    // This check is now more robust. It will initially be null, but the initState
    // will set the state and trigger a rebuild, showing the topic.
    if (sessionState == null || sessionState.isFinished) {
      // If the session is finished, show the "Done!" screen.
      // This also handles the initial frame before the session is started.
      if (sessionState?.isFinished == true) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('All done for now!', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
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
      // Show a loading indicator for the very first frame.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentTopic = sessionState.currentTopic!;
    final totalTopics = sessionState.topics.length;
    final currentIndex = sessionState.currentIndex + 1;

    // The rest of the build method is identical to before.
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviewing ($currentIndex / $totalTopics)'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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

  Widget _buildReviewButton({
    required WidgetRef ref,
    required String text,
    required Color color,
    required ReviewAction action,
    bool isSmall = false,
  }) {
    return ElevatedButton(
      onPressed: () {
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