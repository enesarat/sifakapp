import "dart:collection";

import "package:sifakapp/features/medication_reminder/data/data_sources/asset_medication_catalog_data_source.dart";

import "../../domain/entities/medication_catalog_entry.dart";
import "../../domain/entities/medication_category.dart";
import "../../domain/repositories/medication_catalog_repository.dart";
import "../mappers/medication_catalog_entry_mapper.dart";
import "../mappers/medication_category_mapper.dart";

class MedicationCatalogRepositoryImpl implements MedicationCatalogRepository {
  MedicationCatalogRepositoryImpl(this._dataSource);

  final AssetMedicationCatalogDataSource _dataSource;

  List<MedicationCatalogEntry>? _entriesCache;
  Map<MedicationCategoryKey, MedicationCategory>? _categoryCache;

  @override
  Future<List<MedicationCatalogEntry>> searchByName(
    String query, {
    int limit = 20,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.length < 3) {
      return const [];
    }

    final entries = await _loadEntries();

    final List<MedicationCatalogEntry> matches = [];
    for (final entry in entries) {
      if (entry.name.toLowerCase().contains(normalized)) {
        matches.add(entry);
        if (matches.length >= limit) {
          break;
        }
      }
    }
    return matches;
  }

  @override
  Future<MedicationCategory?> getCategoryByKey(
    MedicationCategoryKey key,
  ) async {
    final categories = await _loadCategories();
    return categories[key];
  }

  @override
  Future<List<MedicationCategory>> getAllCategories() async {
    final categories = await _loadCategories();
    return List<MedicationCategory>.unmodifiable(categories.values);
  }

  Future<List<MedicationCatalogEntry>> _loadEntries() async {
    if (_entriesCache != null) {
      return _entriesCache!;
    }
    final dtos = await _dataSource.loadEntries();
    _entriesCache =
        dtos.map(MedicationCatalogEntryMapper.toEntity).toList(growable: false);
    return _entriesCache!;
  }

  Future<Map<MedicationCategoryKey, MedicationCategory>>
      _loadCategories() async {
    if (_categoryCache != null) {
      return _categoryCache!;
    }
    final dtos = await _dataSource.loadCategories();
    final mapped = <MedicationCategoryKey, MedicationCategory>{};
    for (final dto in dtos) {
      final entity = MedicationCategoryMapper.toEntity(dto);
      mapped[entity.key] = entity;
    }
    _categoryCache = UnmodifiableMapView(mapped);
    return _categoryCache!;
  }
}
