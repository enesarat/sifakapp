import "dart:convert";

import "package:flutter/services.dart";

import "../models/medication_catalog_entry_dto.dart";
import "../models/medication_category_dto.dart";

class AssetMedicationCatalogDataSource {
  AssetMedicationCatalogDataSource({AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const String _medicationListAsset =
      'assets/data/medications/medication_list.json';
  static const String _medicationCategoriesAsset =
      'assets/data/medications/medication_categories.json';

  List<MedicationCatalogEntryDto>? _cachedEntries;
  List<MedicationCategoryDto>? _cachedCategories;

  Future<List<MedicationCatalogEntryDto>> loadEntries() async {
    if (_cachedEntries != null) {
      return _cachedEntries!;
    }
    final jsonString = await _bundle.loadString(_medicationListAsset);
    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    _cachedEntries = decoded
        .whereType<Map<String, dynamic>>()
        .map(MedicationCatalogEntryDto.fromJson)
        .toList(growable: false);
    return _cachedEntries!;
  }

  Future<List<MedicationCategoryDto>> loadCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }
    final jsonString = await _bundle.loadString(_medicationCategoriesAsset);
    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    _cachedCategories = decoded
        .whereType<Map<String, dynamic>>()
        .map(MedicationCategoryDto.fromJson)
        .toList(growable: false);
    return _cachedCategories!;
  }

  void clearCache() {
    _cachedEntries = null;
    _cachedCategories = null;
  }
}
