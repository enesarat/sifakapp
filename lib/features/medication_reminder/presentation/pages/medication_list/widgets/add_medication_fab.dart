import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sifakapp/core/navigation/app_routes.dart'; // <- app_routes.dart'ı import et
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_bloc.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_event.dart';

class AddMedicationFab extends StatelessWidget {
  const AddMedicationFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        // Form sayfasını go_router ile aç
        final result = await context.push(
          const MedicationFormRoute().location, // "/medications/new"
        );
        // Form başarıyla kaydettiyse (formda context.pop(true) yapıyoruz)
        if (result == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt eklendi.')),
          );
          // Listeyi tazele :
          context.read<MedicationBloc>().add(FetchAllMedications());
        }
      },
      child: const Icon(Icons.add),
    );
  }
}
