import 'package:flutter/material.dart';

class MedicationSaveButton extends StatelessWidget {
  const MedicationSaveButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text("Kaydet"),
      ),
    );
  }
}
