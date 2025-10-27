import 'dart:collection';

import 'package:sifakapp/features/medication_reminder/data/data_sources/asset_medication_catalog_data_source.dart';
import 'package:sifakapp/features/medication_reminder/data/data_sources/custom_medication_catalog_data_source.dart';

import '../../domain/entities/medication_catalog_entry.dart';
import '../../domain/entities/medication_category.dart';
import '../../domain/repositories/medication_catalog_repository.dart';
import '../mappers/medication_catalog_entry_mapper.dart';
import '../mappers/medication_category_mapper.dart';
import '../models/medication_catalog_entry_dto.dart';

class MedicationCatalogRepositoryImpl implements MedicationCatalogRepository {
  MedicationCatalogRepositoryImpl(
    this._assetDataSource,
    this._customDataSource,
  );

  final AssetMedicationCatalogDataSource _assetDataSource;
  final CustomMedicationCatalogDataSource _customDataSource;

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

  @override
  Future<bool> existsByName(String name) async {
    final normalized = name.trim().toLowerCase();
    final entries = await _loadEntries();
    return entries.any((entry) => entry.name.toLowerCase() == normalized);
  }

  @override
  Future<void> addCustomEntry(MedicationCatalogEntry entry) async {
    final existing = await _customDataSource.loadEntries();
    final normalized = entry.name.toLowerCase();
    if (existing.any((e) => e.name.toLowerCase() == normalized)) {
      return;
    }
    if (_entriesCache != null &&
        _entriesCache!.any((e) => e.name.toLowerCase() == normalized)) {
      return;
    }
    final dto = MedicationCatalogEntryMapper.fromEntity(entry);
    await _customDataSource.addEntry(dto);
    _entriesCache = null;
  }

  Future<List<MedicationCatalogEntry>> _loadEntries() async {
    if (_entriesCache != null) {
      return _entriesCache!;
    }
    final assetDtos = await _assetDataSource.loadEntries();
    final customDtos = await _customDataSource.loadEntries();
    final combinedDtos = <MedicationCatalogEntryDto>[
      ...assetDtos,
      ...customDtos,
    ];

    final seen = <String>{};
    final combined = <MedicationCatalogEntry>[];
    for (final dto in combinedDtos) {
      final entity = MedicationCatalogEntryMapper.toEntity(dto);
      final key = entity.name.toLowerCase();
      if (seen.add(key)) {
        combined.add(entity);
      }
    }

    _entriesCache = combined;
    return _entriesCache!;
  }

  Future<Map<MedicationCategoryKey, MedicationCategory>>
      _loadCategories() async {
    if (_categoryCache != null) {
      return _categoryCache!;
    }
    final dtos = await _assetDataSource.loadCategories();
    final mapped = <MedicationCategoryKey, MedicationCategory>{};
    for (final dto in dtos) {
      final entity = MedicationCategoryMapper.toEntity(dto);
      mapped[entity.key] = entity;
    }
    _categoryCache = UnmodifiableMapView(mapped);
    return _categoryCache!;
  }
}
