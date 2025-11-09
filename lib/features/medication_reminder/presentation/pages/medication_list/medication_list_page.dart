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
      body: Stack(
        children: const [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: 110),
              child: MedicationListBody(),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: GlassFloatingNavBar(selected: NavTab.plans),
          ),
        ],
      ),
    );
  }
}
