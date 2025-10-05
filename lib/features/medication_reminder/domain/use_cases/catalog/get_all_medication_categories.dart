import "../../entities/medication_category.dart";
import "../../repositories/medication_catalog_repository.dart";

class GetAllMedicationCategories {
  const GetAllMedicationCategories(this._repository);

  final MedicationCatalogRepository _repository;

  Future<List<MedicationCategory>> call() {
    return _repository.getAllCategories();
  }
}
