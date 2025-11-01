import 'package:flutter/material.dart';

class MedicationDiagnosisField extends StatelessWidget {
  const MedicationDiagnosisField({super.key, required this.controller, required this.validator, this.decoratedPrefixIcon = false, this.prefixColor});
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final bool decoratedPrefixIcon;
  final Color? prefixColor;

  @override
  Widget build(BuildContext context) {
    Widget? prefix;
    if (decoratedPrefixIcon) {
      final color = prefixColor ?? Theme.of(context).colorScheme.secondary;
      prefix = Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.favorite_border, size: 18, color: color),
        ),
      );
    }
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "Tan��",
        prefixIcon: prefix,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      validator: validator,
    );
  }
}



