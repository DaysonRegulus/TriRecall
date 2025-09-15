import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/subject_model.dart';
import 'package:trirecall/features/subjects/controller/subject_controller.dart';
import 'package:trirecall/features/subjects/screens/add_subject_screen.dart';

class SubjectsListScreen extends ConsumerWidget {
  const SubjectsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider that fetches the list of subjects.
    final subjectsAsyncValue = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Subjects')),
      // The FloatingActionButton is the standard way to add new items.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddSubjectScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: subjectsAsyncValue.when(
        // The data is available, show the list.
        data: (subjects) {
          if (subjects.isEmpty) {
            return const Center(child: Text('No subjects yet. Add one!'));
          }
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final color = Color(int.parse(subject.color.substring(1, 7), radix: 16) + 0xFF000000);
              return ListTile(
                leading: CircleAvatar(backgroundColor: color),
                title: Text(subject.title, style: const TextStyle(fontSize: 18)),
                // We'll add an onTap later to see topics in this subject.
              );
            },
          );
        },
        // The data is still loading, show a progress indicator.
        loading: () => const Center(child: CircularProgressIndicator()),
        // An error occurred.
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}