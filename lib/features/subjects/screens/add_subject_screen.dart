import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trirecall/features/auth/widgets/auth_button.dart';
import 'package:trirecall/features/auth/widgets/auth_field.dart';
import 'package:trirecall/features/subjects/controller/subject_controller.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:trirecall/core/utils/color_utils.dart';
import 'package:trirecall/core/models/subject_model.dart';

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
  final Subject? existingSubject;
  const AddSubjectScreen({super.key, this.existingSubject});
  
  

  @override
  ConsumerState<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends ConsumerState<AddSubjectScreen> {
  final titleController = TextEditingController();
  String selectedColorHex = '#BB86FC'; // Default to our primary purple

  @override
  void initState() {
    super.initState();
    // Check if we are in "Edit" mode.
    if (widget.existingSubject != null) {
      // If so, pre-fill the form fields with the existing data.
      titleController.text = widget.existingSubject!.title;
      selectedColorHex = widget.existingSubject!.color;
    }
  }

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

  void _submitForm() {
    final title = titleController.text.trim();
    if (title.isNotEmpty) {
      final bool isEditing = widget.existingSubject != null;
      
      if (isEditing) {
        // If we are editing, create an updated subject object using copyWith.
        final updatedSubject = widget.existingSubject!.copyWith(
          title: title,
          color: selectedColorHex,
        );
        ref.read(subjectControllerProvider.notifier).updateSubject(
              subject: updatedSubject,
              ref: ref,
            );
      } else {
        // Otherwise, call the original createSubject method.
        ref.read(subjectControllerProvider.notifier).createSubject(
              title: title,
              color: selectedColorHex,
              ref: ref,
            );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(subjectControllerProvider);
    final bool isEditing = widget.existingSubject != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Subject' : 'Add New Subject')),
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
              // Use the boolean to set the button text.
              buttonText: isLoading
                  ? (isEditing ? 'Updating...' : 'Adding...')
                  : (isEditing ? 'Update Subject' : 'Add Subject'),
              onPressed: isLoading ? () {} : _submitForm,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}