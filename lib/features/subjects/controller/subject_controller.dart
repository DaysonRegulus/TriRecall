import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/subject_model.dart';
import 'package:trirecall/core/services/database_helper.dart';

// This provider will expose the SubjectController.
final subjectControllerProvider = StateNotifierProvider<SubjectController, bool>((ref) {
  return SubjectController();
});

// This provider will asynchronously fetch and provide the list of all subjects.
// The `FutureProvider` is perfect for one-off data fetching operations.
final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  return await DatabaseHelper.instance.getAllSubjects();
});

class SubjectController extends StateNotifier<bool> {
  // isLoading state
  SubjectController() : super(false);

  Future<void> createSubject({
    required String title,
    required String color,
    required WidgetRef ref, // We need the ref to invalidate the provider
  }) async {
    state = true;
    final newSubject = Subject(title: title, color: color);
    await DatabaseHelper.instance.createSubject(newSubject);
    
    // This is a crucial step. After adding a new subject, we tell Riverpod
    // that the old data from `subjectsProvider` is no longer valid.
    // This will cause it to re-fetch the list, and our UI will update automatically.
    ref.invalidate(subjectsProvider);
    
    state = false;
  }
}