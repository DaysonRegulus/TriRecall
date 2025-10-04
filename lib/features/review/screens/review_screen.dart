// lib/features/review/screens/review_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/topic_model.dart';
import 'package:trirecall/core/services/srs_service.dart';
import 'package:trirecall/features/review/controller/review_controller.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final List<Topic> dueTopics;
  const ReviewScreen({super.key, required this.dueTopics});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewSessionProvider.notifier).startSession(widget.dueTopics);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(reviewSessionProvider);

    if (sessionState == null || sessionState.isFinished) {
      if (sessionState?.isFinished == true) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('All done for now!', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                // Using FilledButton for the primary action on this screen.
                FilledButton(
                  onPressed: () {
                    ref.read(reviewSessionProvider.notifier).endSession();
                    Navigator.of(context).pop();
                  },
                  // Make it less wide than the default full-width style
                  style: FilledButton.styleFrom(minimumSize: const Size(200, 50)),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        );
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentTopic = sessionState.currentTopic!;
    final totalTopics = sessionState.topics.length;
    final currentIndex = sessionState.currentIndex + 1;

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
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text(
                      currentTopic.notes,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // --- REFACTORED BUTTONS ---
            _buildReviewButton(
              context: context, // Pass context to get theme colors
              text: 'Revised',
              action: ReviewAction.revised,
              buttonType: _ButtonType.primary,
            ),
            const SizedBox(height: 12),
            _buildReviewButton(
              context: context,
              text: 'Needs Work',
              action: ReviewAction.needsWork,
              buttonType: _ButtonType.secondary,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildReviewButton(
                    context: context,
                    text: 'Mastered',
                    action: ReviewAction.mastered,
                    buttonType: _ButtonType.tertiary,
                    isSmall: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReviewButton(
                    context: context,
                    text: 'Reset',
                    action: ReviewAction.reset,
                    buttonType: _ButtonType.destructive,
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

  // Helper enum for clarity
  _buildReviewButton({
    required BuildContext context,
    required String text,
    required ReviewAction action,
    required _ButtonType buttonType,
    bool isSmall = false,
  }) {
    final VoidCallback onPressed = () {
      ref.read(reviewSessionProvider.notifier).reviewCurrentTopic(action);
    };

    final baseStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 16),
      textStyle: TextStyle(
        fontSize: isSmall ? 16 : 18,
        fontWeight: FontWeight.bold,
      ),
    );

    switch (buttonType) {
      case _ButtonType.primary: // Revised
        return FilledButton(
          onPressed: onPressed,
          style: baseStyle,
          child: Text(text),
        );
      case _ButtonType.secondary: // Needs Work
        return FilledButton.tonal(
          onPressed: onPressed,
          style: baseStyle,
          child: Text(text),
        );
      case _ButtonType.tertiary: // Mastered
        return ElevatedButton(
          onPressed: onPressed,
          style: baseStyle,
          child: Text(text),
        );
      case _ButtonType.destructive: // Reset
        return FilledButton(
          onPressed: onPressed,
          // For destructive actions, we explicitly override the color
          // to the theme's error color for clear user feedback.
          style: baseStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.error),
            foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.onError),
          ),
          child: Text(text),
        );
    }
  }
}

// An enum makes the build method cleaner and more readable.
enum _ButtonType { primary, secondary, tertiary, destructive }