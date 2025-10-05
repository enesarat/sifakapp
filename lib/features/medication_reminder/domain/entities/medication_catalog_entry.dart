import 'medication_category.dart';

class MedicationCatalogEntry {
  final String name;
  final String? barcode;
  final MedicationCategoryKey? categoryKey;
  final int? pieces;

  const MedicationCatalogEntry({
    required this.name,
    this.barcode,
    this.categoryKey,
    this.pieces,
  });
}
