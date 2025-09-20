import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/topic_model.dart';
import 'package:trirecall/core/services/database_helper.dart';
import 'package:trirecall/core/models/date_card_model.dart';
import 'package:trirecall/features/review/controller/due_items_controller.dart';

// Provider for the controller itself.
final topicControllerProvider = StateNotifierProvider<TopicController, bool>((ref) {
  return TopicController();
});

// A new provider to fetch ALL topics. We'll use this later in Part C.
final allTopicsProvider = FutureProvider<List<Topic>>((ref) async {
  // We need a method in DatabaseHelper for this. We'll add it soon.
  return await DatabaseHelper.instance.getAllTopics();
});

final topicsForSubjectProvider =
    FutureProvider.family<List<Topic>, int>((ref, subjectId) async {
  // We invalidate the provider if the list of all topics changes,
  // ensuring this view is always fresh.
  ref.watch(allTopicsProvider);
  return await DatabaseHelper.instance.getTopicsForSubject(subjectId);
});

class TopicController extends StateNotifier<bool> {
  // isLoading state
  TopicController() : super(false);

  Future<void> createTopic({
    required int subjectId,
    required String title,
    required String notes,
    required DateTime studiedOn,
    required WidgetRef ref,
  }) async {
    state = true;

    // 1. Find the DateCard for the selected 'studiedOn' date.
    DateCard? parentDateCard = await DatabaseHelper.instance.getDateCardByDate(studiedOn);

    // 2. If no DateCard exists (e.g., user picked a Sunday or a date
    // outside the schedule), create one on the fly. This makes the app more robust.
    if (parentDateCard == null) {
      final newDateCard = DateCard(
        studyDate: studiedOn,
        nextDue: DateTime(studiedOn.year, studiedOn.month, studiedOn.day).add(const Duration(days: 1)),
      );
      await DatabaseHelper.instance.createDateCard(newDateCard);
      // Now, fetch it again to get its newly assigned ID.
      parentDateCard = await DatabaseHelper.instance.getDateCardByDate(studiedOn);
    }

    final now = DateTime.now();
    final newTopic = Topic(
      subjectId: subjectId,
      dateCardId: parentDateCard!.id, // Safe to use '!' because we just created it if it was null.
      title: title,
      notes: notes,
      studiedOn: studiedOn,
      // The due date is always calculated from the 'studiedOn' date.
      nextDue: DateTime(studiedOn.year, studiedOn.month, studiedOn.day)
          .add(const Duration(days: 1)),
      lastReviewedAt: now,
      createdAt: now,
    );

    await DatabaseHelper.instance.createTopic(newTopic);

    // Invalidate the 'allTopicsProvider' so any screen listening to it will update.
    ref.invalidate(allTopicsProvider);

    state = false;
  }

  Future<void> deleteTopic({
    required int topicId,
    required WidgetRef ref,
  }) async {
    // We don't need a loading state for a quick operation like delete.
    await DatabaseHelper.instance.deleteTopic(topicId);

    // CRITICAL STEP: After deletion, we must invalidate all providers that
    // show topic data to force them to refresh and update the UI.
    ref.invalidate(allTopicsProvider);
    ref.invalidate(topicsForSubjectProvider); // Invalidate the entire family
    ref.invalidate(dueItemsProvider); // Invalidate the "Today" screen provider
  }
}