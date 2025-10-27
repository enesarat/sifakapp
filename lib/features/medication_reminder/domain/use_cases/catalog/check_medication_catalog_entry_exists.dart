import '../../repositories/medication_catalog_repository.dart';

class CheckMedicationCatalogEntryExists {
  const CheckMedicationCatalogEntryExists(this._repository);

  final MedicationCatalogRepository _repository;

  Future<bool> call(String name) {
    return _repository.existsByName(name);
  }
}
