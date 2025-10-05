import "../../entities/medication_catalog_entry.dart";
import "../../repositories/medication_catalog_repository.dart";

class SearchMedicationCatalog {
  const SearchMedicationCatalog(this._repository);

  final MedicationCatalogRepository _repository;

  Future<List<MedicationCatalogEntry>> call(
    String query, {
    int limit = 20,
  }) {
    return _repository.searchByName(query, limit: limit);
  }
}
