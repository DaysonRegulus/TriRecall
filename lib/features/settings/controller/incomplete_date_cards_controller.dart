import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/date_card_model.dart';
import 'package:trirecall/core/services/database_helper.dart';
import 'package:trirecall/features/review/controller/due_items_controller.dart';
import 'package:trirecall/features/settings/controller/date_card_management_controller.dart';

// A new provider to fetch ONLY the incomplete Date Cards.
final incompleteDateCardsProvider =
    FutureProvider.autoDispose<List<DateCard>>((ref) {
  // We watch these other providers. If a date card is deleted or a review
  // happens, this provider will automatically refresh.
  ref.watch(allDateCardsProvider);
  ref.watch(dueItemsProvider);
  return DatabaseHelper.instance.getIncompleteDateCards();
});

final incompleteDateCardsControllerProvider =
    Provider.autoDispose<IncompleteDateCardsController>((ref) {
  return IncompleteDateCardsController(ref: ref);
});

class IncompleteDateCardsController {
  final Ref _ref;
  IncompleteDateCardsController({required Ref ref}) : _ref = ref;

  /// Toggles the `is_incomplete` flag for a given DateCard.
  Future<void> toggleIncompleteStatus(DateCard dateCard) async {
    // Create a new DateCard object with the boolean flag flipped.
    final updatedDateCard = dateCard.copyWith(
      isIncomplete: !dateCard.isIncomplete,
    );

    await DatabaseHelper.instance.updateDateCard(updatedDateCard);

    // Invalidate all providers that might be displaying this DateCard or its status.
    _ref.invalidate(incompleteDateCardsProvider);
    _ref.invalidate(allDateCardsProvider); // The management screen
    _ref.invalidate(dueItemsProvider);     // The "Today" dashboard
  }
}