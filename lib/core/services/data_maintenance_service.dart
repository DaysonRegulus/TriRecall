import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:trirecall/core/models/date_card_model.dart';
import 'package:trirecall/core/models/topic_model.dart';
import 'package:trirecall/core/services/database_helper.dart';
import 'package:trirecall/core/services/srs_service.dart';

class DataMaintenanceService {
  final SRSService _srsService = SRSService();

  /// Checks for and applies decay to any topics or date cards that have not
  /// been reviewed in the last 30 days.
  Future<void> applyDecay() async {
    final db = await DatabaseHelper.instance.database;
    final decayThreshold = DateTime.now().subtract(const Duration(days: 30));
    final decayThresholdString = decayThreshold.toIso8601String();

    print('DECAY CHECK: Running decay check for items not reviewed since $decayThreshold');

    // --- Decay Topics ---
    final decayedTopicMaps = await db.query(
      'topics',
      where: 'status = ? AND interval_index > 0 AND last_reviewed_at < ?',
      whereArgs: ['active', decayThresholdString],
    );

    for (var map in decayedTopicMaps) {
      final topic = Topic.fromMap(map);
      final newIndex = max(topic.intervalIndex - 1, 0);
      final updatedTopic = topic.copyWith(
        intervalIndex: newIndex,
        // We use the SRSService intervals to correctly calculate the new due date.
        nextDue: DateTime.now().add(Duration(days: SRSService.intervals[newIndex])),
      );
      await db.update('topics', updatedTopic.toMap(), where: 'id = ?', whereArgs: [updatedTopic.id]);
      print('DECAY APPLIED: Topic "${updatedTopic.title}" decayed to interval $newIndex.');
    }

    // --- Decay Date Cards ---
    final decayedDateCardMaps = await db.query(
      'date_cards',
      where: 'status = ? AND interval_index > 0 AND last_reviewed_at < ?',
      whereArgs: ['active', decayThresholdString],
    );

    for (var map in decayedDateCardMaps) {
      final dateCard = DateCard.fromMap(map);
      final newIndex = max(dateCard.intervalIndex - 1, 0);
      final updatedDateCard = dateCard.copyWith(
        intervalIndex: newIndex,
        nextDue: DateTime.now().add(Duration(days: SRSService.intervals[newIndex])),
      );
      await db.update('date_cards', updatedDateCard.toMap(), where: 'id = ?', whereArgs: [updatedDateCard.id]);
      print('DECAY APPLIED: DateCard for ${updatedDateCard.studyDate} decayed to interval $newIndex.');
    }
  }
}