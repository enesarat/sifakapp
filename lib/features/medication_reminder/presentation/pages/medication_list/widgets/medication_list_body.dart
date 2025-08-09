import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/medication/medication_bloc.dart';
import '../../../blocs/medication/medication_state.dart';

import 'empty_medication_state.dart';
import 'medication_list_view.dart';
import 'error_medication_state.dart'; // ← eklendi

class MedicationListBody extends StatelessWidget {
  const MedicationListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicationBloc, MedicationState>(
      builder: (context, state) {
        if (state is MedicationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MedicationError) {
          return ErrorMedicationState(message: state.message);
        }

        if (state is MedicationLoaded) {
          if (state.medications.isEmpty) {
            return const EmptyMedicationState();
          }
          return MedicationListView(medications: state.medications);
        }

        // MedicationInitial veya beklenmeyen durumlar için:
        return const EmptyMedicationState();
      },
    );
  }
}
