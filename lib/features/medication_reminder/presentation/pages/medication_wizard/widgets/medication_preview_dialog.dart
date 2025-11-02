import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:sifakapp/features/medication_reminder/data/models/medication_model.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_category.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/medication_wizard_state.dart';

import '../../../utils/time_utils.dart';
import '../../../utils/medication_icon_utils.dart';
// no direct field widgets used here; plain UI only

/// Shows the Step 3 preview dialog with glassmorphism styling.
/// Returns true if user confirms save; false/null otherwise.
Future<bool?> showMedicationPreviewDialog(
  BuildContext context, {
  required MedicationWizardState wiz,
  Color? accent,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    // Darker scrim to make background feel deeper
    barrierColor: Colors.black.withOpacity(0.48),
    builder: (ctx) => _MedicationPreviewDialog(wiz: wiz, accent: accent),
  );
}

class _MedicationPreviewDialog extends StatelessWidget {
  const _MedicationPreviewDialog({required this.wiz, this.accent});

  final MedicationWizardState wiz;
  final Color? accent;

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  List<TimeOfDay> _resolvedTimes() {
    if (wiz.timeScheduleMode == ScheduleMode.manual && wiz.manualTimes.isNotEmpty) {
      return wiz.manualTimes;
    }
    return generateEvenlySpacedTimes(wiz.dailyDosage);
  }

  // Fully opaque badge background, slightly lighter than dialog card
  Color _badgeBg(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    if (theme.brightness == Brightness.dark) {
      final hsl = HSLColor.fromColor(cs.surface);
      final lighter = hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0));
      return lighter.toColor();
    } else {
      // Near-white, fully opaque, subtly brighter than glass card
      return const Color(0xFFF7F9FF);
    }
  }

  String _startLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(wiz.startDate.year, wiz.startDate.month, wiz.startDate.day);
    if (d == today) return 'Bugün';
    if (d == today.add(const Duration(days: 1))) return 'Yarın';
    final dd = wiz.startDate.day.toString().padLeft(2, '0');
    final mm = wiz.startDate.month.toString().padLeft(2, '0');
    final yyyy = wiz.startDate.year.toString();
    return '$dd.$mm.$yyyy tarihinde';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final primary = accent ?? cs.primary;
    final times = _resolvedTimes();
    final timesLabel = times.map(_fmtTime).join(', ');

    final categoryKey = wiz.selectedCategoryKey ?? MedicationCategoryKey.oralCapsule;
    final icon = iconForCategoryKey(categoryKey);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Glass card
            Container(
              width: 480, // keep a sensible max width
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              decoration: BoxDecoration(
                // Slightly brighter card for better contrast against darker scrim
                color: theme.brightness == Brightness.dark
                    ? cs.surface.withOpacity(0.50)
                    : Colors.white.withOpacity(0.36),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  // More pronounced outline
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.14)
                      : Colors.white.withOpacity(0.40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    wiz.nameController.text.trim().isEmpty
                        ? 'İlaç'
                        : wiz.nameController.text.trim(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Opacity(
                    opacity: 0.90,
                    child: Text(
                      '${_startLabel()} · $timesLabel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFA7F3D0),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Detail card inside
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? cs.surface.withOpacity(0.50)
                          : Colors.white.withOpacity(0.50),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        _RowItem(
                          leadingBg: primary.withOpacity(0.10),
                          icon: Icons.calendar_month,
                          iconColor: primary,
                          title: 'Günlük Plan',
                          subtitle: wiz.isEveryDay ? 'Her gün' : 'Seçili günler',
                        ),
                        const SizedBox(height: 12),
                        _RowItem(
                          leadingBg: primary.withOpacity(0.10),
                          icon: Icons.schedule,
                          iconColor: primary,
                          title: 'Saat Planı',
                          subtitle: timesLabel,
                        ),
                        const SizedBox(height: 12),
                        _RowItem(
                          leadingBg: primary.withOpacity(0.10),
                          icon: Icons.restaurant,
                          iconColor: primary,
                          title: wiz.isAfterMeal ? 'Yemekten Sonra' : 'Yemekten Önce',
                          subtitle: wiz.isAfterMeal
                              ? 'Tok karnına alınacak'
                              : 'Aç karnına alınacak',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: const Text('Kaydet'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Düzenle',
                      style: TextStyle(color: primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            // Floating circle icon
            Positioned(
              top: -36,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  // Slightly lighter than dialog, fully opaque
                  color: _badgeBg(context),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.50), width: 4),
                ),
                child: Center(
                  child: Icon(icon, color: primary, size: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.leadingBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final Color leadingBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: leadingBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
