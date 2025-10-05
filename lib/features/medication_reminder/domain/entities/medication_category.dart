enum MedicationCategoryKey {
  oralCapsule('oral_capsule'),
  topicalSemisolid('topical_semisolid'),
  parenteral('parenteral'),
  oralSyrup('oral_syrup'),
  oralSuspension('oral_suspension'),
  oralDrops('oral_drops'),
  oralSolution('oral_solution');

  final String value;

  const MedicationCategoryKey(this.value);

  static MedicationCategoryKey? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    for (final key in MedicationCategoryKey.values) {
      if (key.value == value) {
        return key;
      }
    }
    return null;
  }
}

class MedicationCategory {
  final int id;
  final MedicationCategoryKey key;
  final String label;
  final List<String> keywords;

  const MedicationCategory({
    required this.id,
    required this.key,
    required this.label,
    required this.keywords,
  });
}
