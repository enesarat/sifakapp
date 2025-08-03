import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/medication_bloc.dart';
import '../bloc/medication_event.dart';
import '../bloc/medication_state.dart';
import 'medication_form_page.dart';

class MedicationListPage extends StatelessWidget {
  const MedicationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medications")),
      body: BlocBuilder<MedicationBloc, MedicationState>(
        builder: (context, state) {
          if (state is MedicationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MedicationLoaded) {
            return ListView.builder(
              itemCount: state.medications.length,
              itemBuilder: (context, index) {
                final med = state.medications[index];
                return ListTile(
                  title: Text(med.name),
                  subtitle: Text(
                    'Time: ${TimeOfDay.fromDateTime(med.expirationDate).format(context)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<MedicationBloc>().add(RemoveMedication(med.id));
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No Medications"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MedicationFormPage(),
            ),
          );
        },
      ),
    );
  }
}
