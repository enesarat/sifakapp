class MedicationCategoryDto {
  final int id;
  final String key;
  final String label;
  final List<String> keywords;

  const MedicationCategoryDto({
    required this.id,
    required this.key,
    required this.label,
    required this.keywords,
  });

  factory MedicationCategoryDto.fromJson(Map<String, dynamic> json) {
    return MedicationCategoryDto(
      id: json['id'] as int,
      key: json['key'] as String,
      label: json['label'] as String,
      keywords: (json['keywords'] as List<dynamic>)
          .map((dynamic e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'key': key,
      'label': label,
      'keywords': keywords,
    };
  }
}
