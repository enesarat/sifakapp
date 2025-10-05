import '../../domain/entities/medication_catalog_entry.dart';
import '../../domain/entities/medication_category.dart';
import '../models/medication_catalog_entry_dto.dart';

class MedicationCatalogEntryMapper {
  static MedicationCatalogEntry toEntity(MedicationCatalogEntryDto dto) {
    return MedicationCatalogEntry(
      name: dto.name,
      barcode: _normalizeEmpty(dto.barcode),
      categoryKey: MedicationCategoryKey.fromValue(_normalizeEmpty(dto.type)),
      pieces: dto.pieces,
    );
  }

  static MedicationCatalogEntryDto fromEntity(MedicationCatalogEntry entity) {
    return MedicationCatalogEntryDto(
      name: entity.name,
      barcode: entity.barcode,
      type: entity.categoryKey?.value,
      pieces: entity.pieces,
    );
  }

  static String? _normalizeEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }
}
