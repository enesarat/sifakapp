import 'package:flutter/material.dart';

class EmptyMedicationState extends StatelessWidget {
  const EmptyMedicationState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Kayıtlı ilaç bulunmuyor.'));
  }
}
