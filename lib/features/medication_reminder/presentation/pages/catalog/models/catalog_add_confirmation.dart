class CatalogAddConfirmationArgs {
  const CatalogAddConfirmationArgs({
    required this.name,
    required this.totalPills,
    this.typeLabel,
  });

  final String name;
  final int totalPills;
  final String? typeLabel;
}

enum CatalogAddDecision { add, skip }
