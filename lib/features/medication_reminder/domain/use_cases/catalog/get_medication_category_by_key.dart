import "../../entities/medication_category.dart";
import "../../repositories/medication_catalog_repository.dart";

class GetMedicationCategoryByKey {
  const GetMedicationCategoryByKey(this._repository);

  final MedicationCatalogRepository _repository;

  Future<MedicationCategory?> call(MedicationCategoryKey key) {
    return _repository.getCategoryByKey(key);
  }
}
