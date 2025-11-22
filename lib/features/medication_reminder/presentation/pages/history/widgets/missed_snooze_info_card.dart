import 'package:flutter/material.dart';

class MissedSnoozeInfoCard extends StatelessWidget {
  const MissedSnoozeInfoCard({
    super.key,
    required this.palette,
    required this.onSnoozeTap,
    this.onClose,
    this.clearing = false,
  });

  final PaletteLike palette;
  final VoidCallback onSnoozeTap;
  final VoidCallback? onClose;
  final bool clearing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.amberBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.amberBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.warning_amber_rounded, color: palette.amberText),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kaçırılan Doz Bilgisi',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  splashRadius: 18,
                ),
            ],
          ),
          Text(
            'Aşağıdaki dozlar son 24 saat içinde kaçırıldı. '
            'Bildirimleri susturmak bir sonraki kaçırılan doza kadar '
            'uyarıları durduracaktır.',
            style: TextStyle(fontSize: 13, color: palette.amberSubtext),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.amberSubtext,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: clearing ? null : onSnoozeTap,
              icon: const Icon(Icons.notifications_off),
              label: Text(clearing ? 'Bekleyin…' : 'Bildirimleri Sustur'),
            ),
          ),
        ],
      ),
    );
  }
}

// A minimal palette contract to avoid coupling; satisfied by _Palette in history_page.dart
abstract class PaletteLike {
  Color get amberBg;
  Color get amberBorder;
  Color get amberText;
  Color get amberSubtext;
}
