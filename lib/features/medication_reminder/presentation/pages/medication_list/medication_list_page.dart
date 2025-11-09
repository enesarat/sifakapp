import 'package:flutter/material.dart';
import 'widgets/medication_list_appbar.dart';
import 'widgets/medication_list_body.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/glass_floating_nav_bar.dart';

class MedicationListPage extends StatelessWidget {
  const MedicationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const MedicationListAppBar(),
      body: const MedicationListBody(),
      bottomNavigationBar: const SafeArea(
        minimum: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GlassFloatingNavBar(selected: NavTab.plans),
      ),
    );
  }
}
