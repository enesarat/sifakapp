import 'package:flutter/material.dart';

class EmptyMedicationState extends StatelessWidget {
  const EmptyMedicationState({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.medication, color: cs.primary, size: 48),
            ),
            const SizedBox(height: 16),
            Text('Kayıtlı ilaç yok', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "Yeni bir ilaç eklemek için sağ alttaki '+' butonuna dokunun.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
