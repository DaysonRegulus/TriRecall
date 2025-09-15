import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/features/auth/widgets/auth_button.dart'; // We can reuse this!
import 'package:trirecall/features/auth/widgets/auth_field.dart'; // And this!
import 'package:trirecall/features/subjects/controller/subject_controller.dart';

// We'll offer a predefined list of colors for simplicity.
const List<String> subjectColors = [
  '#FF5733', // Red-Orange
  '#33FF57', // Green
  '#3357FF', // Blue
  '#FF33A1', // Pink
  '#A133FF', // Purple
  '#FFC300', // Yellow
  '#00C4FF', // Light Blue
];

class AddSubjectScreen extends ConsumerStatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  ConsumerState<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends ConsumerState<AddSubjectScreen> {
  final titleController = TextEditingController();
  String selectedColor = subjectColors[0]; // Default color

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void onAddSubject() {
    if (titleController.text.trim().isNotEmpty) {
      ref.read(subjectControllerProvider.notifier).createSubject(
            title: titleController.text.trim(),
            color: selectedColor,
            ref: ref,
          );
      // Go back to the previous screen after adding.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(subjectControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Subject')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Subject Title', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            AuthField(
              hintText: 'e.g., Data Structures',
              controller: titleController,
            ),
            const SizedBox(height: 30),
            const Text('Color', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            // A grid to display our color choices.
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: subjectColors.map((colorHex) {
                // We parse the hex string to a Color object.
                final color = Color(int.parse(colorHex.substring(1, 7), radix: 16) + 0xFF000000);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = colorHex;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == colorHex ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(), // Pushes the button to the bottom
            AuthButton(
              buttonText: isLoading ? 'Adding...' : 'Add Subject',
              onPressed: isLoading ? () {} : onAddSubject,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}