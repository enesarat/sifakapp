import '../../domain/entities/medication_category.dart';
import '../models/medication_category_dto.dart';

class MedicationCategoryMapper {
  static MedicationCategory toEntity(MedicationCategoryDto dto) {
    final key = MedicationCategoryKey.fromValue(dto.key);
    if (key == null) {
      throw ArgumentError('Unknown medication category key: ${dto.key}');
    }
    return MedicationCategory(
      id: dto.id,
      key: key,
      label: dto.label,
      keywords: List<String>.unmodifiable(dto.keywords),
    );
  }

  static MedicationCategoryDto fromEntity(MedicationCategory entity) {
    return MedicationCategoryDto(
      id: entity.id,
      key: entity.key.value,
      label: entity.label,
      keywords: List<String>.from(entity.keywords),
    );
  }
}
