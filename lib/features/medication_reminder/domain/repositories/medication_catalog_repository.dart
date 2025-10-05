import "../entities/medication_catalog_entry.dart";
import "../entities/medication_category.dart";

abstract class MedicationCatalogRepository {
  Future<List<MedicationCatalogEntry>> searchByName(
    String query, {
    int limit = 20,
  });

  Future<MedicationCategory?> getCategoryByKey(
    MedicationCategoryKey key,
  );

  Future<List<MedicationCategory>> getAllCategories();
}
