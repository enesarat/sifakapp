import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import 'package:sifakapp/core/navigation/app_route_paths.dart';
import 'package:sifakapp/core/service_locator.dart';
import 'package:sifakapp/core/validations/validator.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_category.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/catalog/get_all_medication_categories.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/widgets/widgets.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/medication_wizard_state.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/widgets/wizard_progress_header.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/wizard_palette.dart';

class Step1MedicationInfoPage extends StatefulWidget {
  const Step1MedicationInfoPage({super.key});

  @override
  State<Step1MedicationInfoPage> createState() => _Step1MedicationInfoPageState();
}

class _Step1MedicationInfoPageState extends State<Step1MedicationInfoPage> {
  final _formKey = GlobalKey<FormState>();
  String? _typeError;

  // Wizard state (created on step 1)
  late final MedicationWizardState _wiz = MedicationWizardState();

  // Categories
  late final GetAllMedicationCategories _getAllMedicationCategories =
      sl<GetAllMedicationCategories>();
  List<MedicationCategory> _categories = const [];
  bool _isCategoryLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _getAllMedicationCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isCategoryLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = const [];
        _isCategoryLoading = false;
      });
    }
  }

  void _goNext() {
    if (!_formKey.currentState!.validate()) return;
    if (_wiz.selectedCategoryKey == null) {
      setState(() => _typeError = 'Tür/Kategori seçiniz');
      return;
    }

    // GoRouter ile 'extra' göndermek için pushNamed kullan
    // AppRoutes.medicationWizardStep2 -> route adınız (String) olmalı.
    context.push(AppRoutePaths.medicationsNewStep2, extra: _wiz);

    // Eğer typed route helper kullanıyorsanız ve constructor parametreli ise,
    // şu şekilde de olabilir (projenize göre):
    // MedicationWizardStep2Route(wiz: _wiz).push(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final localTheme = theme.copyWith(
      colorScheme: cs.copyWith(primary: WizardPalette.primary),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: WizardPalette.primary,
        selectionColor: WizardPalette.primarySelection,
        selectionHandleColor: WizardPalette.primary,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(width: 2, color: WizardPalette.primary),
        ),
      ),
    );
    return Theme(
      data: localTheme,
      child: Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text('İlaç Ekle'),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: WizardPalette.primary),
              onPressed: _goNext,
              child: const Text('İlerle'),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WizardProgressHeader(activeStep: 1),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MedicationNameField(
                    controller: _wiz.nameController,
                    validator: Validator.validateMedicationName,
                    decoratedPrefixIcon: true,
                    prefixColor: const Color(0xFF8A5CF6),
                    onManuallyEdited: () {
                      setState(() {
                        _wiz.setCategory(null);
                        _wiz.pillsController.text = '';
                        _typeError = null;
                      });
                    },
                    onSuggestionSelected: (entry) {
                      setState(() {
                        _wiz.setCategory(entry.categoryKey);
                        if (entry.categoryKey == MedicationCategoryKey.oralCapsule &&
                            entry.pieces != null) {
                          _wiz.pillsController.text = entry.pieces.toString();
                        }
                        _typeError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  MedicationDiagnosisField(
                    controller: _wiz.diagnosisController,
                    validator: Validator.validateDiagnosis,
                    decoratedPrefixIcon: true,
                    prefixColor: const Color(0xFFF472B6),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MedicationTypeField(
                        categories: _categories,
                        selectedKey: _wiz.selectedCategoryKey,
                        isLoading: _isCategoryLoading,
                        decoratedPrefixIcon: true,
                        prefixColor: const Color(0xFF22D3EE),
                        onChanged: (key) => setState(() {
                          _wiz.setCategory(key);
                          _typeError = null;
                        }),
                      ),
                      if (_typeError != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _typeError!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: WizardPalette.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: WizardPalette.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Endişelenme, bu sadece başlangıç! Diğer detayları sonraki adımlarda ekleyeceğiz.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: WizardPalette.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
