import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/medication/medication_bloc.dart';
import '../../../blocs/medication/medication_event.dart';

class ErrorMedicationState extends StatelessWidget {
  const ErrorMedicationState({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<MedicationBloc>().add(FetchAllMedications()),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
