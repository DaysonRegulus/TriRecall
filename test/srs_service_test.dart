// This import is necessary for all test files.
import 'package:flutter_test/flutter_test.dart';
import 'package:trirecall/core/models/topic_model.dart';
import 'package:trirecall/core/services/srs_service.dart';

void main() {
  // `group` allows us to organize related tests together.
  group('SRSService Tests', () {
    late SRSService srsService;
    late DateTime now;
    late DateTime today;

    // `setUp` is a special function that runs before each test.
    // This is perfect for creating fresh instances for each test.
    setUp(() {
      srsService = SRSService();
      now = DateTime.now();
      today = DateTime(now.year, now.month, now.day);
    });

    // `test` defines a single, specific test case.
    test('A new topic marked as Revised should have interval index 1 and be due in 3 days', () {
      // Arrange: Create the initial state for the test.
      final newTopic = Topic(
        subjectId: 1,
        title: 'Test',
        notes: '',
        studiedOn: now,
        lastReviewedAt: now,
        createdAt: now,
        intervalIndex: 0, // A brand new topic starts at index 0.
      );

      // Act: Perform the action we want to test.
      final updatedTopic = srsService.processReview(
        currentTopic: newTopic,
        action: ReviewAction.revised,
      );

      // Assert: Check if the result is what we expect.
      expect(updatedTopic.intervalIndex, 1);
      // The next interval is the one at index 1, which is 3 days.
      expect(updatedTopic.nextDue, today.add(const Duration(days: 3)));
      expect(updatedTopic.status, 'active');
    });

    test('A topic at index 2 marked as Needs Work should have interval index 1', () {
      // Arrange
      final existingTopic = Topic(
        subjectId: 1,
        title: 'Test',
        notes: '',
        studiedOn: now,
        lastReviewedAt: now,
        createdAt: now,
        intervalIndex: 2, // Topic has been revised twice before.
      );

      // Act
      final updatedTopic = srsService.processReview(
        currentTopic: existingTopic,
        action: ReviewAction.needsWork,
      );

      // Assert
      expect(updatedTopic.intervalIndex, 1);
      // The next interval is the one at index 1, which is 3 days.
      expect(updatedTopic.nextDue, today.add(const Duration(days: 3)));
    });

    test('A topic at the last interval marked as Revised should become Mastered', () {
      // Arrange
      final advancedTopic = Topic(
        subjectId: 1,
        title: 'Test',
        notes: '',
        studiedOn: now,
        lastReviewedAt: now,
        createdAt: now,
        intervalIndex: 4, // The last interval before mastered (30 days).
      );

      // Act
      final updatedTopic = srsService.processReview(
        currentTopic: advancedTopic,
        action: ReviewAction.revised,
      );

      // Assert
      expect(updatedTopic.status, 'mastered');
      expect(updatedTopic.nextDue, isNull);
      expect(updatedTopic.intervalIndex, 5);
    });

    test('A topic marked as Reset should have interval index 0 and be due tomorrow', () {
      // Arrange
      final existingTopic = Topic(
        subjectId: 1,
        title: 'Test',
        notes: '',
        studiedOn: now,
        lastReviewedAt: now,
        createdAt: now,
        intervalIndex: 3, // An advanced topic.
      );

      // Act
      final updatedTopic = srsService.processReview(
        currentTopic: existingTopic,
        action: ReviewAction.reset,
      );

      // Assert
      expect(updatedTopic.intervalIndex, 0);
      expect(updatedTopic.nextDue, today.add(const Duration(days: 1)));
    });
  });
}