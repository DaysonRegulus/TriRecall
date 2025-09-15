import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/topic_model.dart';
import 'package:trirecall/core/services/database_helper.dart';
import 'package:trirecall/core/services/srs_service.dart';
import 'package:trirecall/features/topics/controller/topic_controller.dart';

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