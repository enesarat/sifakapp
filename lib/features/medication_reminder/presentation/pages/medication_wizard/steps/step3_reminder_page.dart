import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sifakapp/core/validations/validator.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_category.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/medication_wizard_state.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/widgets/wizard_progress_header.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/widgets/widgets.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/wizard_palette.dart';

class Step3ReminderPage extends StatefulWidget {
  const Step3ReminderPage({super.key, this.wiz});

  final MedicationWizardState? wiz;

  @override
  State<Step3ReminderPage> createState() => _Step3ReminderPageState();
}

class _Step3ReminderPageState extends State<Step3ReminderPage> {
  final _formKey = GlobalKey<FormState>();
  MedicationWizardState? _wiz;

  @override
  void initState() {
    super.initState();
    _wiz = widget.wiz;
  }

  bool get _isCapsuleSelected => _wiz?.selectedCategoryKey == MedicationCategoryKey.oralCapsule;

  Future<void> _pickExpirationDate() async {
    final now = DateTime.now();
    final initial = _wiz!.expirationDate ?? DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null && mounted) setState(() => _wiz!.setExpirationDate(picked));
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    // Preview dialog will be implemented next step.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önizleme akışı eklenecek.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_wiz == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
          title: const Text('İlaç Ekle'),
          centerTitle: true,
        ),
        body: Center(
          child: FilledButton(style: FilledButton.styleFrom(backgroundColor: WizardPalette.primary),
            onPressed: () => context.pop(),
            child: const Text('Akışı Baştan Başlat'),
          ),
        ),
      );
    }
    final cs = Theme.of(context).colorScheme;


    return Scaffold(
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
            child: FilledButton(style: FilledButton.styleFrom(backgroundColor: WizardPalette.primary),
              onPressed: _onSave,
              child: const Text('Kaydet'),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WizardProgressHeader(activeStep: 3),
              const SizedBox(height: 8),
              // Daily dosage quick adjust block (optional, mirrors design button +/-)
              // Keeping dosage primarily in Step 2; we don't duplicate controls here to avoid conflict.

              const SizedBox(height: 8),
              Text('Stok Takibi', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              MedicationPillsField(
                controller: _wiz!.pillsController,
                validator: Validator.validatePills,
                labelText: _isCapsuleSelected ? 'Toplam Hap Sayısı' : 'Toplam Doz Sayısı',
              ),
              const SizedBox(height: 16),
              MedicationExpirationDate(
                expirationDate: _wiz!.expirationDate,
                onPickDate: _pickExpirationDate,
                onClear: () => setState(() => _wiz!.setExpirationDate(null)),
              ),
              const SizedBox(height: 16),
              MedicationMealInfo(
                isAfterMeal: _wiz!.isAfterMeal,
                hoursBeforeOrAfterMeal: _wiz!.hoursBeforeOrAfterMeal,
                onChanged: (v) => setState(() => _wiz!.setMealAfter(v)),
                onSliderChanged: (v) => setState(() => _wiz!.setMealHours(v.toInt())),
              ),

            ],
          ),
        ),
      ),
    );
  }
}





















