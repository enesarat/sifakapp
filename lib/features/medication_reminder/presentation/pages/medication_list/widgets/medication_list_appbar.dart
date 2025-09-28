import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';

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
            context.push(const MissedDosesRoute().location);
          },
        ),
      ],
    );
  }
}




