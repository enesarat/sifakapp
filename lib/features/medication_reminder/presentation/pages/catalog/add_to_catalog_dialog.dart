import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/catalog_add_confirmation.dart';

class AddToCatalogDialog extends StatelessWidget {
  const AddToCatalogDialog({
    super.key,
    required this.name,
    required this.totalPills,
    this.typeLabel,
  });

  final String name;
  final int totalPills;
  final String? typeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yeni ila\u00e7 katalo\u011fu kayd\u0131',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tan\u0131ml\u0131 olmayan ilac\u0131 katalo\u011fa eklemek ister misiniz?',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Kapat',
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SummaryRow(label: 'İlaç Adı', value: name),
              const SizedBox(height: 12),
              _SummaryRow(label: 'Toplam Adet', value: totalPills.toString()),
              if (typeLabel != null && typeLabel!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SummaryRow(label: 'Tür', value: typeLabel!),
              ],
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 12,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(CatalogAddDecision.skip),
                      child: const Text('Eklemeden Devam Et'),
                    ),
                    ElevatedButton(
                      onPressed: () => context.pop(CatalogAddDecision.add),
                      child: const Text('Ekle'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
