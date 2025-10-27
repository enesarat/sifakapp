import '../../entities/medication_catalog_entry.dart';
import '../../entities/medication_category.dart';
import '../../repositories/medication_catalog_repository.dart';

class AddCustomMedicationCatalogEntry {
  const AddCustomMedicationCatalogEntry(this._repository);

  final MedicationCatalogRepository _repository;

  Future<void> call(AddCustomMedicationCatalogEntryParams params) {
    final entry = MedicationCatalogEntry(
      name: params.name,
      barcode: null,
      categoryKey: params.categoryKey,
      pieces: params.pieces,
    );
    return _repository.addCustomEntry(entry);
  }
}

class AddCustomMedicationCatalogEntryParams {
  const AddCustomMedicationCatalogEntryParams({
    required this.name,
    this.categoryKey,
    this.pieces,
  });

  final String name;
  final MedicationCategoryKey? categoryKey;
  final int? pieces;
}
