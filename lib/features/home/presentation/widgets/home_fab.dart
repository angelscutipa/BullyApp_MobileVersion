import 'package:flutter/material.dart';
import '../../../nfc/presentacion/add_bully_to_chip.dart';

class HomeFab extends StatelessWidget {
  final bool visible;

  const HomeFab({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: FloatingActionButton.extended(
        onPressed: () {
          print("🔘 ¡FAB PRESIONADO!");
          AddBullyToChip.mostrarDialogo(context);
        },
        icon: const Icon(Icons.nfc),
        label: const Text('Vincular Chip'),
        backgroundColor: const Color.fromARGB(255, 163, 68, 0),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color.fromARGB(255, 255, 105, 0),
            width: 2,
          ),
        ),
      ),
    );
  }
}
