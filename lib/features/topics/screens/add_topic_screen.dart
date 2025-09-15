import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/core/models/subject_model.dart';
import 'package:trirecall/features/auth/widgets/auth_button.dart';
import 'package:trirecall/features/auth/widgets/auth_field.dart';
import 'package:trirecall/features/subjects/controller/subject_controller.dart';
import 'package:trirecall/features/topics/controller/topic_controller.dart';

class AddTopicScreen extends ConsumerStatefulWidget {
  const AddTopicScreen({super.key});

  @override
  ConsumerState<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends ConsumerState<AddTopicScreen> {
  final titleController = TextEditingController();
  final notesController = TextEditingController();
  Subject? selectedSubject; // Can be null initially

  DateTime selectedDate = DateTime.now(); // Defaults to today

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void onAddTopic() {
    // Basic validation
    if (titleController.text.trim().isNotEmpty && selectedSubject != null) {
      ref.read(topicControllerProvider.notifier).createTopic(
            subjectId: selectedSubject!.id!, // We know id is not null here
            title: titleController.text.trim(),
            notes: notesController.text.trim(),
            ref: ref,
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // We watch both the list of subjects (for the dropdown) and the
    // loading state of the topic controller (for the button).
    final subjectsAsyncValue = ref.watch(subjectsProvider);
    final isLoading = ref.watch(topicControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Topic')),
      body: subjectsAsyncValue.when(
        data: (subjects) {
          // If there are no subjects, we can't add a topic.
          if (subjects.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'You must create a Subject before you can add a Topic.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }

          // If selectedSubject is null after the subjects have loaded,
          // default to the first one in the list.
          if (selectedSubject == null) {
            selectedSubject = subjects[0];
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Topic Title', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                AuthField(
                  hintText: 'e.g., Big O Notation',
                  controller: titleController,
                ),
                const SizedBox(height: 30),
                const Text('Subject', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                // Dropdown menu to select a subject.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade700, width: 2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Subject>(
                      isExpanded: true,
                      value: selectedSubject,
                      onChanged: (Subject? newValue) {
                        setState(() {
                          selectedSubject = newValue;
                        });
                      },
                      items: subjects.map<DropdownMenuItem<Subject>>((Subject subject) {
                        return DropdownMenuItem<Subject>(
                          value: subject,
                          child: Text(subject.title),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Notes', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                AuthField(
                  hintText: 'Add your revision notes here...',
                  controller: notesController,
                ),
                const SizedBox(height: 50),
                AuthButton(
                  buttonText: isLoading ? 'Adding...' : 'Add Topic',
                  onPressed: isLoading ? () {} : onAddTopic,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}