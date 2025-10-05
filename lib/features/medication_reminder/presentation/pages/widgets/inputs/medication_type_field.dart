import 'package:flutter/material.dart';

import 'package:sifakapp/features/medication_reminder/domain/entities/medication_category.dart';

class MedicationTypeField extends StatelessWidget {
  const MedicationTypeField({
    super.key,
    required this.categories,
    required this.selectedKey,
    required this.onChanged,
    this.isLoading = false,
  });

  final List<MedicationCategory> categories;
  final MedicationCategoryKey? selectedKey;
  final ValueChanged<MedicationCategoryKey?> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading && categories.isEmpty) {
      return InputDecorator(
        decoration: const InputDecoration(labelText: 'Tür'),
        child: const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    final hasSelection =
        categories.any((category) => category.key == selectedKey);
    final dropdownValue = hasSelection ? selectedKey : null;

    final items = <DropdownMenuItem<MedicationCategoryKey?>>[
      const DropdownMenuItem<MedicationCategoryKey?>(
        value: null,
        child: Text('Tür seçiniz'),
      ),
      ...categories.map(
        (category) => DropdownMenuItem<MedicationCategoryKey?>(
          value: category.key,
          child: Text(category.label),
        ),
      ),
    ];

    return DropdownButtonFormField<MedicationCategoryKey?>(
      value: dropdownValue,
      items: items,
      decoration: const InputDecoration(labelText: 'Tür'),
      onChanged: isLoading ? null : onChanged,
    );
  }
}
