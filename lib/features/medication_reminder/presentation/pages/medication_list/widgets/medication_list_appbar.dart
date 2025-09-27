import 'package:flutter/material.dart';
import '../../missed/missed_doses_page.dart';

class MedicationListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MedicationListAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('İlaçlarım'),
      actions: [
        IconButton(
          tooltip: 'Kaçırılan dozlar',
          icon: const Icon(Icons.notification_important_outlined),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MissedDosesPage()),
            );
          },
        ),
      ],
    );
  }
}

