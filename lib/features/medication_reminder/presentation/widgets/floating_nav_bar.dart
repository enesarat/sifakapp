import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';

enum NavTab { home, plans, history, dose }

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.selected});

  final NavTab selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final glass = isLight
        ? Colors.white.withOpacity(0.55)
        : cs.surface.withOpacity(0.55);
    final borderColor = Colors.white.withOpacity(isLight ? 0.30 : 0.15);

    return SizedBox(
      height: 96,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Bar body
          Container(
            height: 76,
            decoration: BoxDecoration(
              color: glass,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  selected: selected == NavTab.home,
                  onTap: () => const HomeRoute().go(context),
                ),
                _NavItem(
                  icon: Icons.calendar_month,
                  label: 'Plans',
                  selected: selected == NavTab.plans,
                  onTap: () => const PlansRoute().go(context),
                ),
                const SizedBox(width: 56),
                _NavItem(
                  icon: Icons.history,
                  label: 'History',
                  selected: selected == NavTab.history,
                  onTap: () => const MissedDosesRoute().go(context),
                ),
                _NavItem(
                  icon: Icons.medication_outlined,
                  label: 'Dose',
                  selected: selected == NavTab.dose,
                  onTap: () => const DoseNowRoute().go(context),
                ),
              ],
            ),
          ),
          // Floating add button
          Positioned(
            bottom: 30,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () => context.push(const MedicationFormRoute().location),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.onTap, required this.selected});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected
        ? cs.primary
        : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.85);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color, fontWeight: selected ? FontWeight.w800 : FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
