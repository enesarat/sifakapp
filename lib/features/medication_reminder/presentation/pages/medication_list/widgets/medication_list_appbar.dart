import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';

class MedicationListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MedicationListAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 8),
          Icon(Icons.home, color: cs.onSurface),
          const SizedBox(width: 8),
          Text(
            'İlaçlarım',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => context.push(const MissedDosesRoute().location),
          icon: Icon(Icons.notifications_off_outlined, color: cs.primary),
          label: Text(
            'Kaçırılanlar',
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

