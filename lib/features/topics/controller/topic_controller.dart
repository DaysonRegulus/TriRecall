import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/topic_model.dart';
import 'package:trirecall/core/services/database_helper.dart';

// Provider for the controller itself.
final topicControllerProvider = StateNotifierProvider<TopicController, bool>((ref) {
  return TopicController();
});

// A new provider to fetch ALL topics. We'll use this later in Part C.
final allTopicsProvider = FutureProvider<List<Topic>>((ref) async {
  // We need a method in DatabaseHelper for this. We'll add it soon.
  return await DatabaseHelper.instance.getAllTopics();
});


class TopicController extends StateNotifier<bool> {
  // isLoading state
  TopicController() : super(false);

  Future<void> createTopic({
    required int subjectId,
    required String title,
    required String notes,
    required WidgetRef ref,
  }) async {
    state = true;

    final now = DateTime.now();
    final newTopic = Topic(
      subjectId: subjectId,
      title: title,
      notes: notes,
      studiedOn: now, // Defaults to today
      // Topic starts with the first interval, due tomorrow.
      nextDue: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
      lastReviewedAt: now,
      createdAt: now,
    );

    await DatabaseHelper.instance.createTopic(newTopic);

    // Invalidate the 'allTopicsProvider' so any screen listening to it will update.
    ref.invalidate(allTopicsProvider);

    state = false;
  }
}