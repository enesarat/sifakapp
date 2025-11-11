import 'package:flutter/material.dart';
import '../../widgets/frosted_blob_background.dart';
import '../../widgets/floating_top_nav_bar.dart';
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
      body: Stack(
        children: const [
          Positioned.fill(child: FrostedBlobBackground()),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 84, 0, 0),
              child: MedicationListBody(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 8,
            child: SafeArea(top: true, bottom: false, child: FloatingTopNavBar(title: 'Planlar')),
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
