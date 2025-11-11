import 'package:flutter/material.dart';

class FloatingTopNavBar extends StatelessWidget {
  const FloatingTopNavBar({super.key, required this.title, this.onMenuTap, this.trailing});

  final String title;
  final VoidCallback? onMenuTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final glass = isLight ? Colors.white.withOpacity(0.55) : cs.surface.withOpacity(0.55);
    final borderColor = Colors.white.withOpacity(isLight ? 0.30 : 0.15);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: glass,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            const SizedBox(width: 6),
            IconButton(onPressed: onMenuTap ?? () {}, icon: const Icon(Icons.menu)),
            Expanded(
              child: Center(
                child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 6),
            trailing ??
                CircleAvatar(radius: 18, backgroundColor: cs.primary.withOpacity(0.25), child: const Icon(Icons.person)),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

