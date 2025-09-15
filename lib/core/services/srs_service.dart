import 'dart:math';
import 'package:trirecall/core/models/topic_model.dart';

// Using an enum for review actions is a best practice. It prevents typos that
// you might get from using raw strings like "revised" or "needs_work".
enum ReviewAction {
  mastered,
  revised,
  needsWork,
  reset,
}

class SRSService {
  // Our fixed SRS schedule (in days). The index corresponds to interval_index.
  static const List<int> _intervals = [1, 3, 7, 15, 30];

  /// Takes a topic and a review action, and returns the topic with its
  /// new SRS state calculated.
  Topic processReview({
    required Topic currentTopic,
    required ReviewAction action,
  }) {
    // Get today's date at midnight for consistent date calculations.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int newIntervalIndex = currentTopic.intervalIndex;
    DateTime? newNextDue = currentTopic.nextDue;
    String newStatus = currentTopic.status;

    // A switch statement is a very clean way to handle the different actions.
    switch (action) {
      case ReviewAction.revised:
        newIntervalIndex = min(currentTopic.intervalIndex + 1, _intervals.length);
        if (newIntervalIndex >= _intervals.length) {
          // The topic has graduated to "Mastered".
          newStatus = 'mastered';
          newNextDue = null;
        } else {
          newStatus = 'active';
          newNextDue = today.add(Duration(days: _intervals[newIntervalIndex]));
        }
        break;

      case ReviewAction.needsWork:
        newIntervalIndex = max(currentTopic.intervalIndex - 1, 0);
        newStatus = 'active';
        newNextDue = today.add(Duration(days: _intervals[newIntervalIndex]));
        break;
        
      case ReviewAction.mastered:
        newIntervalIndex = _intervals.length;
        newStatus = 'mastered';
        newNextDue = null;
        break;

      case ReviewAction.reset:
        newIntervalIndex = 0;
        newStatus = 'active';
        // When reset, the next review is always tomorrow.
        newNextDue = today.add(const Duration(days: 1));
        break;
    }

    // Use the copyWith method to create a new Topic object with the updated values.
    return currentTopic.copyWith(
      intervalIndex: newIntervalIndex,
      nextDue: newNextDue,
      setNextDueToNull: newNextDue == null, // Use our special flag
      status: newStatus,
      lastReviewedAt: now,
    );
  }
}