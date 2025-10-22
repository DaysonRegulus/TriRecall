import 'package:trirecall/core/models/date_card_model.dart';
import 'package:trirecall/core/services/database_helper.dart';
import 'package:trirecall/core/services/settings_service.dart';

class ScheduleService {
  final SettingsService _settingsService = SettingsService();

  /// Generates all missing DateCards from the user's saved start date
  /// up to today, based on their selected study days.
  Future<void> generateMissingDateCards() async {
    final startDate = await _settingsService.getStartDate();
    final studyDays = await _settingsService.getStudyDays();

    if (startDate == null) {
      return;
    }

    // 1. Get the current moment.
    final now = DateTime.now();
    // 2. "Normalize" it to create a date at midnight. This removes the time component.
    final today = DateTime(now.year, now.month, now.day);
    // This loop now works reliably because we are comparing dates without times.
    // It will correctly loop up to and including `today`.
    for (var day = startDate; day.isBefore(today.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
      // The `weekday` property returns 1 for Monday and 7 for Sunday.
      // We check if the current day in the loop is one of the user's selected study days.
      if (studyDays.contains(day.weekday)) {
        final dateCard = DateCard(
          studyDate: day,
          // The first due date is always the next day.
          nextDue: DateTime(day.year, day.month, day.day).add(const Duration(days: 1)),
        );
        // This will create the card only if it doesn't already exist.
        await DatabaseHelper.instance.createDateCard(dateCard);
      }
    }
  }
}