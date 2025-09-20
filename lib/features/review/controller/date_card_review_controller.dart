import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/date_card_model.dart';
import 'package:trirecall/core/models/topic_model.dart';
import 'package:trirecall/core/services/database_helper.dart';
import 'package:trirecall/core/services/srs_service.dart';
import 'package:trirecall/features/review/controller/due_items_controller.dart';

// This provider will fetch the list of topics for the DateCard currently being reviewed.
// It uses `.family` because we need to pass in the DateCard's ID.
final topicsInDateCardProvider = FutureProvider.family<List<Topic>, int>((ref, dateCardId) {
  return DatabaseHelper.instance.getTopicsForDateCard(dateCardId);
});

// The provider for our new controller.
final dateCardReviewControllerProvider =
    StateNotifierProvider.autoDispose<DateCardReviewController, bool>((ref) {
  return DateCardReviewController(ref: ref);
});

class DateCardReviewController extends StateNotifier<bool> {
  final Ref _ref;
  DateCardReviewController({required Ref ref})
      : _ref = ref,
        super(false); // isLoading state

  /// This is the core logic for the mixed-marking review.
  Future<void> processDateCardReview({
    required DateCard dateCard,
    required ReviewAction bulkAction,
    required Map<int, ReviewAction> topicOverrides,
  }) async {
    state = true;
    final db = await DatabaseHelper.instance.database;
    final srsService = SRSService();

    // Using a transaction is a critical best practice. It ensures that ALL of
    // the updates succeed, or NONE of them do. This prevents a crash halfway
    // through from leaving your data in an inconsistent state.
    await db.transaction((txn) async {
      // 1. Get all topics for this DateCard.
      final allTopicsInDateCard = await txn.query('topics', where: 'date_card_id = ?', whereArgs: [dateCard.id]);

      // 2. Loop through each topic and process its review.
      for (var topicMap in allTopicsInDateCard) {
        final topic = Topic.fromMap(topicMap);
        
        // Decide which action to use: the override or the bulk action.
        final action = topicOverrides[topic.id] ?? bulkAction;
        
        final updatedTopic = srsService.processReview(
          currentTopic: topic,
          action: action,
        );
        
        // Update the topic within the transaction.
        await txn.update('topics', updatedTopic.toMap(), where: 'id = ?', whereArgs: [updatedTopic.id]);
      }

      // 3. Get the SRS results for the DateCard by "tricking" the service.
      final srsResultAsTopic = srsService.processReview(
        currentTopic: Topic(
          id: dateCard.id,
          subjectId: 0,
          title: '',
          notes: '',
          studiedOn: dateCard.studyDate,
          intervalIndex: dateCard.intervalIndex,
          status: dateCard.status,
          createdAt: DateTime.now(),
          lastReviewedAt: DateTime.now(),
        ),
        action: bulkAction,
      );
      
      // 4. Create the final, valid, updated DateCard object using ITS OWN copyWith method.
      // We combine the original DateCard's data with the new SRS results.
      final updatedDateCard = dateCard.copyWith(
        intervalIndex: srsResultAsTopic.intervalIndex,
        nextDue: srsResultAsTopic.nextDue,
        setNextDueToNull: srsResultAsTopic.nextDue == null,
        status: srsResultAsTopic.status,
      );
      
      // 5. Update the DateCard in the database using the fully correct object.
      await txn.update(
        'date_cards', 
        updatedDateCard.toMap(),
        where: 'id = ?', 
        whereArgs: [updatedDateCard.id],
      );
    });

    // 6. Invalidate providers to refresh the UI.
    _ref.invalidate(dueItemsProvider);

    state = false;
  }
}