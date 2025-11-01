import 'package:flutter/material.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/wizard_palette.dart';

class WizardProgressHeader extends StatelessWidget {
  const WizardProgressHeader({
    super.key,
    required this.activeStep,
  });

  final int activeStep; // 1..3

  Widget _circle(BuildContext context, int step, String label,
      {bool done = false, bool active = false}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = WizardPalette.primary;
    final bg = active
        ? accent
        : done
            ? accent.withOpacity(0.15)
            : cs.surfaceVariant;
    final fg = active ? Colors.white : (done ? accent : cs.onSurface);
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active || done ? accent : cs.outlineVariant,
              width: active ? 0 : 2,
            ),
          ),
          alignment: Alignment.center,
          child: done
              ? Icon(Icons.check, size: 22, color: fg)
              : Text('$step',
                  style: TextStyle(
                      color: fg, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: active
                ? accent
                : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget line(bool filled) => Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(top: 8),
            color: filled ? WizardPalette.primary : Theme.of(context).dividerColor,
          ),
        );

    // Dynamic bottom spacing: slightly increase on taller screens
    final mq = MediaQuery.of(context);
    final h = mq.size.height;
    final extra = ((h.clamp(480.0, 900.0) as double) - 480.0) / (900.0 - 480.0) * 8.0; // 0..8
    // Apply the same extra spacing once more (double the incremental part)
    final bottom = 12.0 + (extra * 2);
    return Padding(
      padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: bottom),
      child: Row(
        children: [
          _circle(context, 1, 'İlaç Bilgileri',
              active: activeStep == 1, done: activeStep > 1),
          const SizedBox(width: 8),
          line(activeStep > 1),
          const SizedBox(width: 8),
          _circle(context, 2, 'Dozaj & Sıklık',
              active: activeStep == 2, done: activeStep > 2),
          const SizedBox(width: 8),
          line(activeStep > 2),
          const SizedBox(width: 8),
          _circle(context, 3, 'Stok & Öğün', active: activeStep == 3),
        ],
      ),
    );
  }
}
