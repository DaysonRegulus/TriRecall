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

    // Best Practice: Normalize the date ONCE at the very beginning.
    // This ensures all subsequent logic uses a clean, time-stripped date.
    final normalizedStudyDate = DateTime(studiedOn.year, studiedOn.month, studiedOn.day);

    // Now, we search for the parent DateCard using this normalized date.
    DateCard? parentDateCard = await DatabaseHelper.instance.getDateCardByDate(normalizedStudyDate);

    // This block now works correctly because it creates and fetches using the same normalized date.
    if (parentDateCard == null) {
      // Create the new DateCard using the CLEAN, NORMALIZED date.
      final newDateCard = DateCard(
        studyDate: normalizedStudyDate,
        nextDue: normalizedStudyDate.add(const Duration(days: 1)),
      );
      await DatabaseHelper.instance.createDateCard(newDateCard);

      // This fetch will now succeed because the data we saved matches the search key.
      parentDateCard = await DatabaseHelper.instance.getDateCardByDate(normalizedStudyDate);
    }

    // This null check is now safe. If parentDateCard is still null here,
    // it indicates a serious, unrecoverable database issue.
    if (parentDateCard == null) {
      // TODO: Implement proper error handling/logging for this edge case.
      // For now, we prevent a crash by stopping execution.
      state = false;
      return;
    }

    final now = DateTime.now();
    final newTopic = Topic(
      subjectId: subjectId,
      // The `!` is now safe to use because of the check above.
      dateCardId: parentDateCard.id,
      title: title,
      notes: notes,
      // We save the topic with the normalized date for consistency.
      studiedOn: normalizedStudyDate,
      // The due date is also calculated from the clean, normalized date.
      nextDue: normalizedStudyDate.add(const Duration(days: 1)),
      lastReviewedAt: now,
      createdAt: now,
    );

    await DatabaseHelper.instance.createTopic(newTopic);

    // Invalidate all relevant providers to ensure the UI updates everywhere.
    ref.invalidate(allTopicsProvider);
    ref.invalidate(dueItemsProvider);
    ref.invalidate(topicsForSubjectProvider);

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