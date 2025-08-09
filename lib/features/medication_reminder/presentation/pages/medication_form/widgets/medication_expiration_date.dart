import 'package:flutter/material.dart';

class MedicationExpirationDate extends StatelessWidget {
  const MedicationExpirationDate({
    super.key,
    required this.expirationDate,
    required this.onPickDate,
  });

  final DateTime expirationDate;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Son Kullanma Tarihi: "),
        TextButton(
          onPressed: onPickDate,
          child: Text("${expirationDate.toLocal()}".split(' ')[0]),
        )
      ],
    );
  }
}
