import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/services/schedule_service.dart';
import 'package:trirecall/core/services/settings_service.dart';

// A simple state class to hold the settings for our UI.
class ScheduleSettingsState {
  final DateTime? startDate;
  final Set<int> studyDays;

  ScheduleSettingsState({this.startDate, required this.studyDays});

  ScheduleSettingsState copyWith({DateTime? startDate, Set<int>? studyDays}) {
    return ScheduleSettingsState(
      startDate: startDate ?? this.startDate,
      studyDays: studyDays ?? this.studyDays,
    );
  }
}

final scheduleControllerProvider =
    StateNotifierProvider.autoDispose<ScheduleController, ScheduleSettingsState?>((ref) {
  return ScheduleController();
});

class ScheduleController extends StateNotifier<ScheduleSettingsState?> {
  final SettingsService _settingsService = SettingsService();
  final ScheduleService _scheduleService = ScheduleService();

  ScheduleController() : super(null);

  Future<void> loadSettings() async {
    final startDate = await _settingsService.getStartDate();
    final studyDays = await _settingsService.getStudyDays();
    // It's safe to set state here because this is usually called
    // in initState before any async gaps.
    if (mounted) {
      state = ScheduleSettingsState(startDate: startDate, studyDays: studyDays);
    }
  }

  Future<void> saveSettingsAndGenerateDateCards(ScheduleSettingsState newSettings) async {
    // We don't need to set a loading state here, as the user is navigated away.
    await _settingsService.saveStartDate(newSettings.startDate!);
    await _settingsService.saveStudyDays(newSettings.studyDays);
    await _scheduleService.generateMissingDateCards();
    
    // Safety check: only update state if the controller is still mounted.
    if (mounted) {
      state = newSettings;
    }
  }
}