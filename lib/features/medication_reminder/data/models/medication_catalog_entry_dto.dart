class MedicationCatalogEntryDto {
  final String name;
  final String? barcode;
  final String? type;
  final int? pieces;

  const MedicationCatalogEntryDto({
    required this.name,
    this.barcode,
    this.type,
    this.pieces,
  });

  factory MedicationCatalogEntryDto.fromJson(Map<String, dynamic> json) {
    return MedicationCatalogEntryDto(
      name: (json['Name'] as String).trim(),
      barcode: (json['Barcode'] as String?)?.trim(),
      type: (json['Type'] as String?)?.trim(),
      pieces: json['Pieces'] == null ? null : (json['Pieces'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'Name': name,
      'Barcode': barcode,
      'Type': type,
      'Pieces': pieces,
    };
  }
}
