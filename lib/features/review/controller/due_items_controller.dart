import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/due_item_model.dart';
import 'package:trirecall/core/services/database_helper.dart';

// This is our new primary provider for the HomeScreen.
final dueItemsProvider = FutureProvider.autoDispose<List<DueItem>>((ref) async {
  final dbHelper = DatabaseHelper.instance;

  // 1. Fetch the due DateCards first.
  final due_DateCards = await dbHelper.getDue_DateCards();
  
  // 2. Get their IDs to use in the next query.
  final due_DateCardIds = due_DateCards.map((dc) => dc.id!).toList();
  
  // 3. Fetch the stray topics, passing in the IDs to exclude.
  final due_Stray_Topics = await dbHelper.getDue_Stray_Topics(due_DateCardIds);

  // 4. Map the raw data into our type-safe wrapper classes.
  final List<DueItem> dateCardItems = due_DateCards.map((dc) => DueDateCardItem(dc)).toList();
  final List<DueItem> topicItems = due_Stray_Topics.map((t) => DueTopicItem(t)).toList();

  // 5. Combine the lists and return the final result.
  return [...dateCardItems, ...topicItems];
});