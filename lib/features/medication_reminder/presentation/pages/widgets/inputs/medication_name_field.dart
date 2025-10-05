import "dart:async";

import "package:flutter/material.dart";

import 'package:sifakapp/core/service_locator.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_catalog_entry.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/catalog/search_medication_catalog.dart';

class MedicationNameField extends StatefulWidget {
  const MedicationNameField({
    super.key,
    required this.controller,
    required this.validator,
    this.onSuggestionSelected,
    this.onManuallyEdited,
    this.suggestionLimit = 20,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final ValueChanged<MedicationCatalogEntry>? onSuggestionSelected;
  final VoidCallback? onManuallyEdited;
  final int suggestionLimit;

  @override
  State<MedicationNameField> createState() => _MedicationNameFieldState();
}

class _MedicationNameFieldState extends State<MedicationNameField> {
  late final SearchMedicationCatalog _searchMedicationCatalog;
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _suppressManualCallback = false;
  String _lastRequestedQuery = '';
  List<MedicationCatalogEntry> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _searchMedicationCatalog = sl<SearchMedicationCatalog>();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _suggestions = const [];
        _isLoading = false;
        _hasSearched = false;
      });
    }
  }

  void _onTextChanged(String value) {
    if (_suppressManualCallback) {
      _suppressManualCallback = false;
      return;
    }

    widget.onManuallyEdited?.call();

    final trimmed = value.trim();
    if (trimmed.length < 3) {
      _debounce?.cancel();
      setState(() {
        _suggestions = const [];
        _isLoading = false;
        _hasSearched = false;
      });
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _fetchSuggestions(trimmed);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    _lastRequestedQuery = query;
    setState(() {
      _isLoading = true;
      _hasSearched = false;
    });

    try {
      final results = await _searchMedicationCatalog(
        query,
        limit: widget.suggestionLimit,
      );
      if (!mounted || _lastRequestedQuery != query) {
        return;
      }
      setState(() {
        _suggestions = results;
        _isLoading = false;
        _hasSearched = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = const [];
        _isLoading = false;
        _hasSearched = true;
      });
    }
  }

  void _onSuggestionTap(MedicationCatalogEntry entry) {
    _suppressManualCallback = true;
    widget.controller
      ..text = entry.name
      ..selection = TextSelection.collapsed(offset: entry.name.length);
    setState(() {
      _suggestions = const [];
      _isLoading = false;
      _hasSearched = false;
    });
    widget.onSuggestionSelected?.call(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(labelText: 'İlaç Adı'),
          validator: widget.validator,
          onChanged: _onTextChanged,
        ),
        _SuggestionPanel(
          isVisible: _focusNode.hasFocus &&
              (_isLoading || _suggestions.isNotEmpty || _hasSearched),
          isLoading: _isLoading,
          hasResults: _suggestions.isNotEmpty,
          suggestions: _suggestions,
          onSuggestionTap: _onSuggestionTap,
        ),
      ],
    );
  }
}

class _SuggestionPanel extends StatelessWidget {
  const _SuggestionPanel({
    required this.isVisible,
    required this.isLoading,
    required this.hasResults,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final bool isVisible;
  final bool isLoading;
  final bool hasResults;
  final List<MedicationCatalogEntry> suggestions;
  final ValueChanged<MedicationCatalogEntry> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final borderColor = theme.dividerColor.withOpacity(0.6);

    Widget content;
    if (isLoading) {
      content = const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (hasResults) {
      content = ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 240),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
          itemBuilder: (context, index) {
            final entry = suggestions[index];
            return ListTile(
              dense: true,
              title: Text(entry.name),
              subtitle: entry.barcode != null && entry.barcode!.isNotEmpty
                  ? Text('Barkod: ${entry.barcode}')
                  : null,
              onTap: () => onSuggestionTap(entry),
            );
          },
        ),
      );
    } else {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text('Sonuç bulunamadı'),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: Color(0x1F000000),
          ),
        ],
      ),
      child: content,
    );
  }
}
