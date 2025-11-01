import 'package:flutter/material.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_category.dart';

/// Shared in-memory draft state across wizard steps.
class MedicationWizardState extends ChangeNotifier {
  // Step 1
  final TextEditingController nameController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  MedicationCategoryKey? selectedCategoryKey;

  // Step 2
  DateTime startDate = DateTime.now();
  DateTime? endDate;
  int dailyDosage = 1;
  ScheduleMode timeScheduleMode = ScheduleMode.automatic;
  bool isEveryDay = true;
  ScheduleMode dayScheduleMode = ScheduleMode.manual;
  List<int> usageDays = const [];
  int autoDaysPerWeek = 3; // 1..6
  List<TimeOfDay> manualTimes = const [];
  List<int> autoPreviewDays = const [];

  // Step 3
  final TextEditingController pillsController = TextEditingController();
  DateTime? expirationDate;
  bool isAfterMeal = true;
  int hoursBeforeOrAfterMeal = 0; // 0..3

  void setCategory(MedicationCategoryKey? key) {
    selectedCategoryKey = key;
    notifyListeners();
  }

  void setStartDate(DateTime d) {
    startDate = d;
    notifyListeners();
  }

  void setEndDate(DateTime? d) {
    endDate = d;
    notifyListeners();
  }

  void setDailyDosage(int v) {
    dailyDosage = v;
    notifyListeners();
  }

  void setTimeScheduleMode(ScheduleMode v) {
    timeScheduleMode = v;
    if (v == ScheduleMode.automatic) {
      manualTimes = const [];
    }
    notifyListeners();
  }

  void setEveryDay(bool v) {
    isEveryDay = v;
    notifyListeners();
  }

  void setDayScheduleMode(ScheduleMode v) {
    dayScheduleMode = v;
    if (v == ScheduleMode.manual) {
      usageDays = const [];
    }
    notifyListeners();
  }

  void setUsageDays(List<int> days) {
    usageDays = days;
    notifyListeners();
  }

  void setAutoDaysPerWeek(int v) {
    autoDaysPerWeek = v;
    notifyListeners();
  }

  void setManualTime(int index, TimeOfDay time) {
    final list = manualTimes.toList();
    while (list.length <= index) {
      // Fill missing indices with the selected time as a sensible default
      list.add(time);
    }
    list[index] = time;
    manualTimes = list;
    notifyListeners();
  }

  void setExpirationDate(DateTime? d) {
    expirationDate = d;
    notifyListeners();
  }

  void setMealAfter(bool after) {
    isAfterMeal = after;
    notifyListeners();
  }

  void setMealHours(int hrs) {
    hoursBeforeOrAfterMeal = hrs;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    diagnosisController.dispose();
    pillsController.dispose();
    super.dispose();
  }
}
