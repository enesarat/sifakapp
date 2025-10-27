import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/medication_catalog_entry_dto.dart';

class CustomMedicationCatalogDataSource {
  CustomMedicationCatalogDataSource();

  static const String _fileName = 'medication_list_custom.json';

  File? _cachedFile;

  Future<File> _file() async {
    if (_cachedFile != null) {
      return _cachedFile!;
    }
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_fileName');
    if (!await file.exists()) {
      await file.writeAsString('[]', flush: true);
    }
    _cachedFile = file;
    return file;
  }

  Future<List<MedicationCatalogEntryDto>> loadEntries() async {
    try {
      final file = await _file();
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return const [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(MedicationCatalogEntryDto.fromJson)
            .toList(growable: false);
      }
      return const [];
    } on FormatException {
      return const [];
    }
  }

  Future<void> addEntry(MedicationCatalogEntryDto entry) async {
    final current = await loadEntries();
    if (current.any((e) => e.name.toLowerCase() == entry.name.toLowerCase())) {
      return;
    }
    final updated = List<MedicationCatalogEntryDto>.from(current)..add(entry);
    final file = await _file();
    final data = updated.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(data), flush: true);
  }
}
