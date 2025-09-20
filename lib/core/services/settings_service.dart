import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Use static const for keys to prevent typos.
  static const String _startDateKey = 'study_start_date';
  static const String _studyDaysKey = 'study_days_of_week';

  // --- Start Date Methods ---
  Future<void> saveStartDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_startDateKey, date.toIso8601String());
  }

  Future<DateTime?> getStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_startDateKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  // --- Study Days Methods ---
  // We store the set of active days (e.g., {1, 2, 3, 4, 5, 6}) as a list of strings.
  Future<void> saveStudyDays(Set<int> days) async {
    final prefs = await SharedPreferences.getInstance();
    final dayStrings = days.map((d) => d.toString()).toList();
    await prefs.setStringList(_studyDaysKey, dayStrings);
  }

  Future<Set<int>> getStudyDays() async {
    final prefs = await SharedPreferences.getInstance();
    final dayStrings = prefs.getStringList(_studyDaysKey);
    if (dayStrings != null) {
      return dayStrings.map((s) => int.parse(s)).toSet();
    }
    // Default to Monday-Saturday if no setting is saved.
    return {1, 2, 3, 4, 5, 6};
  }
}