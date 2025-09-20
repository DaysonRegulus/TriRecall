import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/date_card_model.dart';
import 'package:trirecall/core/services/database_helper.dart';
import 'package:trirecall/core/utils/show_snackbar.dart';
import 'package:trirecall/features/review/controller/due_items_controller.dart';

final allDateCardsProvider = FutureProvider.autoDispose<List<DateCard>>((ref) {
  return DatabaseHelper.instance.getAllDateCards();
});

final dateCardManagementControllerProvider =
    StateNotifierProvider.autoDispose<DateCardManagementController, bool>((ref) {
  return DateCardManagementController(ref: ref);
});

class DateCardManagementController extends StateNotifier<bool> {
  final Ref _ref;
  DateCardManagementController({required Ref ref})
      : _ref = ref,
        super(false);

  Future<void> addDateCard(BuildContext context, DateTime date) async {
    final newDateCard = DateCard(
      studyDate: date,
      nextDue: DateTime(date.year, date.month, date.day).add(const Duration(days: 1)),
      lastReviewedAt: DateTime.now(),
    );
    await DatabaseHelper.instance.createDateCard(newDateCard);
    _ref.invalidate(allDateCardsProvider);
    if (context.mounted) showSnackBar(context, 'Date Card added successfully.');
  }

  Future<void> deleteDateCard(BuildContext context, DateCard dateCard) async {
    // --- SAFETY CHECK ---
    final topics = await DatabaseHelper.instance.getTopicsForDateCard(dateCard.id!);
    if (topics.isNotEmpty) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Deletion Failed'),
            content: const Text('Cannot delete this date. Please move or delete all topics from this date first.'),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
          ),
        );
      }
      return;
    }
    // --- END OF SAFETY CHECK ---

    await DatabaseHelper.instance.deleteDateCard(dateCard.id!);
    _ref.invalidate(allDateCardsProvider);
    _ref.invalidate(dueItemsProvider); // In case the deleted card was due
    if (context.mounted) showSnackBar(context, 'Date Card deleted.');
  }
}