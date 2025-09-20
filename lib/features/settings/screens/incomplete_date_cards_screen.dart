import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trirecall/features/settings/controller/incomplete_date_cards_controller.dart';

class IncompleteDateCardsScreen extends ConsumerWidget {
  const IncompleteDateCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch our new provider to get the list of incomplete cards.
    final incompleteCardsAsync = ref.watch(incompleteDateCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incomplete Study Dates'),
      ),
      body: incompleteCardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (dateCards) {
          if (dateCards.isEmpty) {
            return const Center(
              child: Text(
                'All study dates are marked complete!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: dateCards.length,
            itemBuilder: (context, index) {
              final dateCard = dateCards[index];
              return SwitchListTile(
                title: Text(DateFormat.yMMMMEEEEd().format(dateCard.studyDate)),
                subtitle: const Text('Mark as complete'),
                
                // The value of the switch is the opposite of `isIncomplete`.
                // If it's incomplete, the switch is OFF (false).
                value: !dateCard.isIncomplete,
                
                // When the switch is toggled, we call our controller method.
                onChanged: (bool isComplete) {
                  ref.read(incompleteDateCardsControllerProvider).toggleIncompleteStatus(dateCard);
                },
              );
            },
          );
        },
      ),
    );
  }
}