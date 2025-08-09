import 'package:flutter/material.dart';

class MedicationListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MedicationListAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('İlaçlarım'));
  }
}
