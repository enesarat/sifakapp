import 'package:flutter/material.dart';

import 'package:sifakapp/features/medication_reminder/domain/entities/medication_category.dart';

class MedicationTypeField extends StatefulWidget {
  const MedicationTypeField({
    super.key,
    required this.categories,
    required this.selectedKey,
    required this.onChanged,
    this.isLoading = false,
  });

  final List<MedicationCategory> categories;
  final MedicationCategoryKey? selectedKey;
  final ValueChanged<MedicationCategoryKey?> onChanged;
  final bool isLoading;

  @override
  State<MedicationTypeField> createState() => _MedicationTypeFieldState();
}

class _MedicationTypeFieldState extends State<MedicationTypeField>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  final _searchController = TextEditingController();

  List<MedicationCategory> _filtered = const [];
  final GlobalKey _fieldKey = GlobalKey();
  Size _targetSize = const Size(0, 0);

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _filtered = widget.categories;
    _searchController.addListener(_onSearchChanged);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 150),
    );
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    _fade = curve;
    _slide = Tween<Offset>(begin: const Offset(0, -0.02), end: Offset.zero).animate(curve);
  }

  @override
  void didUpdateWidget(covariant MedicationTypeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      _filtered = widget.categories;
    }
  }

  @override
  void dispose() {
    _removeOverlay(immediate: true);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.categories
          : widget.categories
              .where((c) =>
                  c.label.toLowerCase().contains(q) ||
                  c.keywords.any((k) => k.toLowerCase().contains(q)))
              .toList();
    });
    // Rebuild the overlay to reflect filtered results instantly
    _entry?.markNeedsBuild();
  }

  void _toggleOverlay() {
    if (_entry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Measure target size to match overlay width and vertical offset
    final contextObj = _fieldKey.currentContext;
    if (contextObj != null) {
      final box = contextObj.findRenderObject() as RenderBox;
      _targetSize = box.size;
    }

    _entry = OverlayEntry(
      maintainState: true,
      builder: (context) {
        return Stack(
          children: [
            // Tap outside to dismiss
            Positioned.fill(
              child: GestureDetector(onTap: _removeOverlay),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: Offset(0, (_targetSize.height == 0 ? 56 : _targetSize.height) + 8),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: _targetSize.width == 0
                      ? MediaQuery.of(context).size.width
                      : _targetSize.width,
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.light
                              ? Colors.white
                              : cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.brightness == Brightness.light
                                ? Colors.black12
                                : cs.outlineVariant,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'İlaç türü ara...',
                                  prefixIcon: const Icon(Icons.search),
                                  isDense: true,
                                  filled: true,
                                  fillColor: theme.brightness == Brightness.light
                                      ? Colors.grey.shade100
                                      : cs.surfaceVariant,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                            Flexible(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxHeight: 320),
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, bottom: 8),
                                  itemCount: _filtered.length,
                                  itemBuilder: (context, index) {
                                    final c = _filtered[index];
                                    final selected =
                                        c.key == widget.selectedKey;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 6),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        onTap: () {
                                          widget.onChanged(c.key);
                                          _removeOverlay();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? cs.primary
                                                    .withOpacity(0.10)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(_iconFor(c.key),
                                                  color: cs.primary),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  c.label,
                                                  style: TextStyle(
                                                    fontWeight: selected
                                                        ? FontWeight.w700
                                                        : FontWeight.w500,
                                                    color: selected
                                                        ? cs.primary
                                                        : theme
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color,
                                                  ),
                                                ),
                                              ),
                                              if (selected)
                                                Icon(Icons.check_circle,
                                                    color: cs.primary),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, debugRequiredFor: widget).insert(_entry!);
    _controller.forward(from: 0);
  }

  void _removeOverlay({bool immediate = false}) {
    if (_entry == null) return;
    if (immediate) {
      _entry?.remove();
      _entry = null;
      _searchController.clear();
      return;
    }
    _controller.reverse().whenComplete(() {
      _entry?.remove();
      _entry = null;
      _searchController.clear();
    });
  }

  IconData _iconFor(MedicationCategoryKey key) {
    switch (key) {
      case MedicationCategoryKey.oralCapsule:
        return Icons.medication_outlined;
      case MedicationCategoryKey.topicalSemisolid:
        return Icons.icecream_outlined;
      case MedicationCategoryKey.parenteral:
        return Icons.vaccines_outlined;
      case MedicationCategoryKey.oralSyrup:
        return Icons.medication_liquid_outlined;
      case MedicationCategoryKey.oralSuspension:
        return Icons.science_outlined;
      case MedicationCategoryKey.oralDrops:
        return Icons.water_drop_outlined;
      case MedicationCategoryKey.oralSolution:
        return Icons.bubble_chart_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (widget.isLoading && widget.categories.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tür/Kategori',
          filled: true,
          fillColor: cs.surfaceVariant.withOpacity(0.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          prefixIcon: const Icon(Icons.category_outlined),
          isDense: true,
        ),
        child: const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    final selectedLabel = widget.categories
        .firstWhere(
          (c) => c.key == widget.selectedKey,
          orElse: () => const MedicationCategory(
            id: -1,
            key: MedicationCategoryKey.oralCapsule,
            label: '',
            keywords: [],
          ),
        )
        .label;

    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: widget.isLoading ? null : _toggleOverlay,
        child: InputDecorator(
          key: _fieldKey,
          isFocused: _entry != null,
          decoration: InputDecoration(
            labelText: 'Tür/Kategori',
            filled: true,
            fillColor: cs.surfaceVariant.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cs.primary, width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            prefixIcon: const Icon(Icons.category_outlined),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Text(
            selectedLabel.isNotEmpty ? selectedLabel : 'Tür seçiniz',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
