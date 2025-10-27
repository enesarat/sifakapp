import 'dart:async';

import 'package:flutter/material.dart';

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

class _SuggestionPanel extends StatefulWidget {
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
  State<_SuggestionPanel> createState() => _SuggestionPanelState();
}

class _SuggestionPanelState extends State<_SuggestionPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 150),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fade = curve;
    _slide = Tween<Offset>(begin: const Offset(0, -0.02), end: Offset.zero)
        .animate(curve);
    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _SuggestionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isVisible && widget.isVisible) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final borderColor = theme.brightness == Brightness.light
        ? Colors.black12
        : cs.outlineVariant;

    Widget content;
    if (widget.isLoading) {
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
    } else if (widget.hasResults) {
      content = ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          shrinkWrap: true,
          itemCount: widget.suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final entry = widget.suggestions[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => widget.onSuggestionTap(entry),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light
                ? Colors.white
                : cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: content,
        ),
      ),
    );
  }
}
