import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/features/auth/widgets/auth_button.dart';
import 'package:trirecall/features/auth/widgets/auth_field.dart';
import 'package:trirecall/features/subjects/controller/subject_controller.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:trirecall/core/utils/color_utils.dart';

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
  String selectedColorHex = '#BB86FC'; // Default to our primary purple

  void _showColorPicker() {
    // Convert our hex string to a Color object for the picker.
    Color pickerColor = hexToColor(selectedColorHex);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          // We wrap the ColorPicker in a SizedBox to give it a defined width.
          // This prevents its internal layout from overflowing the dialog's boundaries.
          child: SizedBox(
            width: double.infinity,
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              // This property enables the Hex, RGB, and HSV input fields.
              displayThumbColor: true, 

              // We will hide the alpha/transparency slider as we don't need it.
              enableAlpha: false,

              // This provides a label for the Hex input field.
              hexInputBar: true,
            ),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() {
                // When the user confirms, update our state.
                // We convert the Color object back to a hex string for storage.
                selectedColorHex = '#${pickerColor.value.toRadixString(16).substring(2, 8).toUpperCase()}';
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void onAddSubject() {
    if (titleController.text.trim().isNotEmpty) {
      ref.read(subjectControllerProvider.notifier).createSubject(
            title: titleController.text.trim(),
            color: selectedColorHex, // Use the new state variable
            ref: ref,
          );
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
            Row(
              children: [
                // A container to preview the currently selected color.
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: hexToColor(selectedColorHex),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white54, width: 2),
                  ),
                ),
                const SizedBox(width: 20),
                // A button to launch the color picker dialog.
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showColorPicker,
                    child: const Text('Change Color'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
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