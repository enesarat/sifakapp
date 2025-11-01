class AppRoutePaths {
  static const String home = '/';

  // Medication
  static const String medicationsNew = '/medications/new';
  static const String medicationsNewStep1 = '/medications/new/step1';
  static const String medicationsNewStep2 = '/medications/new/step2';
  static const String medicationsNewStep3 = '/medications/new/step3';
  static const String medicationsEdit = '/medications/:id/edit';
  static const String medicationDetails = '/medications/:id/details';
  static const String medicationConfirmDelete = '/medications/:id/confirm-delete';

  // Dose
  static const String doseIntake = '/dose/:id';

  // Misc
  static const String missed = '/missed';
  static const String catalogAddConfirmation = '/catalog/add-confirmation';
}
