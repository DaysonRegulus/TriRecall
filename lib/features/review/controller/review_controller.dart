import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/topic_model.dart';
import 'package:trirecall/core/services/database_helper.dart';
import 'package:trirecall/core/services/srs_service.dart';
import 'package:trirecall/features/topics/controller/topic_controller.dart';
import 'package:flutter/material.dart';

// This provider will fetch the list of topics due for review today.
final dueTopicsProvider = FutureProvider.autoDispose<List<Topic>>((ref) {
  // By watching this, if we add a new topic, this provider will automatically re-run.
  ref.watch(allTopicsProvider);
  return DatabaseHelper.instance.getDueTopics();
});

// Provider for the controller itself.
final reviewControllerProvider =
    StateNotifierProvider.autoDispose<ReviewController, bool>((ref) {
  return ReviewController(ref: ref);
});

class ReviewController extends StateNotifier<bool> {
  final Ref _ref;
  // isLoading state
  ReviewController({required Ref ref})
      : _ref = ref,
        super(false);

  Future<void> processTopicReview({
    required Topic topic,
    required ReviewAction action,
  }) async {
    state = true;

    // 1. Get the updated topic from our SRS service.
    final srsService = SRSService();
    final updatedTopic = srsService.processReview(
      currentTopic: topic,
      action: action,
    );

    // 2. Save the updated topic to the database.
    await DatabaseHelper.instance.updateTopic(updatedTopic);

    // 3. Invalidate providers to trigger UI updates.
    // This tells the dashboard to re-fetch the list of due topics.
    _ref.invalidate(dueTopicsProvider);
    // This ensures our "All Topics" screen will also show the latest state.
    _ref.invalidate(allTopicsProvider);

    state = false;
  }
}

// This class will represent the state of our review session.
@immutable
class ReviewSessionState {
  final List<Topic> topics;
  final int currentIndex;

  const ReviewSessionState({
    required this.topics,
    this.currentIndex = 0,
  });

  // Helper to get the current topic.
  Topic? get currentTopic => topics.isNotEmpty && currentIndex < topics.length
      ? topics[currentIndex]
      : null;

  // Helper to know if the session is finished.
  bool get isFinished => topics.isEmpty || currentIndex >= topics.length;

  ReviewSessionState copyWith({
    List<Topic>? topics,
    int? currentIndex,
  }) {
    return ReviewSessionState(
      topics: topics ?? this.topics,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

// This provider will manage the state of the active review session.
final reviewSessionProvider =
    StateNotifierProvider.autoDispose<ReviewSessionController, ReviewSessionState?>((ref) {
  // We return null initially, as there is no session active.
  return ReviewSessionController(ref: ref);
});

class ReviewSessionController extends StateNotifier<ReviewSessionState?> {
  final Ref _ref;
  ReviewSessionController({required Ref ref})
      : _ref = ref,
        super(null);

  // This method will be called to start a new review session.
  void startSession(List<Topic> dueTopics) {
    state = ReviewSessionState(topics: dueTopics);
  }

  // This method processes the review for the current topic and advances to the next.
  void reviewCurrentTopic(ReviewAction action) {
    if (state != null && state!.currentTopic != null) {
      // Call the other controller to handle the database logic.
      _ref.read(reviewControllerProvider.notifier).processTopicReview(
            topic: state!.currentTopic!,
            action: action,
          );

      // Advance to the next topic in the queue.
      state = state!.copyWith(currentIndex: state!.currentIndex + 1);
    }
  }

  // This method ends the session.
  void endSession() {
    state = null;
  }
}