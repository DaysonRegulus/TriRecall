import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trirecall/features/settings/controller/date_card_management_controller.dart';

class DateCardManagementScreen extends ConsumerWidget {
  const DateCardManagementScreen({super.key});

  Future<void> _addDateCard(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      ref.read(dateCardManagementControllerProvider.notifier).addDateCard(context, picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateCardsAsync = ref.watch(allDateCardsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Study Dates')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addDateCard(context, ref),
        child: const Icon(Icons.add),
        tooltip: 'Add a new Study Date',
      ),
      body: dateCardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (dateCards) {
          if (dateCards.isEmpty) {
            return const Center(child: Text('No study dates found.'));
          }
          return ListView.builder(
            itemCount: dateCards.length,
            itemBuilder: (context, index) {
              final dateCard = dateCards[index];
              return Dismissible(
                key: ValueKey(dateCard.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red.shade800,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  // The actual confirmation happens inside the controller's safety check
                  // Here, we just trigger the controller method.
                  await ref.read(dateCardManagementControllerProvider.notifier).deleteDateCard(context, dateCard);
                  // Return false because we don't want the item to be "dismissed"
                  // if the deletion fails. The provider invalidation will handle the UI update.
                  return false;
                },
                child: ListTile(
                  title: Text(DateFormat.yMMMMEEEEd().format(dateCard.studyDate)),
                  subtitle: Text('Status: ${dateCard.status}, Next Due: ${dateCard.nextDue?.toLocal().toString().split(' ')[0] ?? 'N/A'}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}