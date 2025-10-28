import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/medication.dart';

class DeleteMedicationDialog extends StatelessWidget {
  const DeleteMedicationDialog({
    super.key,
    required this.id,
    this.medication,
  });

  final String id;
  final Medication? medication;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF101D22) : Colors.white;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        );
    final descStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF4C869A),
          fontWeight: FontWeight.w500,
        );

    final name = medication?.name ?? id;

    return Dialog(
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(isDark ? 0.20 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete, color: Colors.red.shade500, size: 28),
            ),
            const SizedBox(height: 12),
            Text('Silme İşlemi', style: titleStyle, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: descStyle,
                children: [
                  const TextSpan(text: '"'),
                  TextSpan(
                    text: name,
                    style: descStyle?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: '" planını silmek istediğinize emin misiniz?'),
                  const TextSpan(text: '\n'),
                  const TextSpan(
                    text:
                        'Bu işlem geri alınamaz ve ilgili hatırlatmalar kaldırılacaktır.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.12)),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(false),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      isDark ? const Color(0xFF2A2F34) : const Color(0xFFE7F0F3),
                  foregroundColor: isDark ? Colors.white : const Color(0xFF0D181B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Vazgeç',
                  style: TextStyle(fontWeight: FontWeight.w700, height: 1.15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Sil',
                  style: TextStyle(fontWeight: FontWeight.w800, height: 1.15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

