import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:bully_app/core/global_variables.dart' as globals;
import 'package:bully_app/core/services/nfc_services.dart';

import 'package:bully_app/features/nfc/presentacion/bully_yellow_button.dart';
import 'package:bully_app/features/nfc/presentacion/hero_card.dart';
import 'package:bully_app/features/nfc/presentacion/details_dogs.dart';

import 'package:bully_app/features/nfc/data/datasources/nfc_remote_data_source.dart';
import 'package:bully_app/features/nfc/data/models/nfc_response_model.dart';

class BullyChipSearchDialog extends StatefulWidget {
  const BullyChipSearchDialog({super.key});

  @override
  State<BullyChipSearchDialog> createState() => _BullyChipSearchDialogState();
}

class _BullyChipSearchDialogState extends State<BullyChipSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final NfcService _nfcService = NfcService();
  bool _isScanning = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    // Aseguramos que si el usuario cierra la pantalla flotante/dialog mientras escanea, el hardware se libere
    FlutterNfcKit.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Botón de cerrar de la barra superior
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const HeroCard(),
                    const SizedBox(height: 32),

                    // CORREGIDO: Botón NFC ahora inicia el HARDWARE primero
                    BullyYellowButton(
                      icon: Icons.nfc,
                      label: 'Iniciar escaneo',
                      onTap: () async {
                        if (_isScanning) return;
                        await _startNfcScanWorkflow(_searchController);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Divisor de diseño
                    Row(
                      children: [
                        Expanded(child: Container(height: 1, color: const Color.fromARGB(90, 255, 140, 0))),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.circle_outlined, color: Color(0xFFFF8C00), size: 12),
                        ),
                        Expanded(child: Container(height: 1, color: const Color.fromARGB(90, 255, 140, 0))),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Formulario de Búsqueda Manual
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color.fromARGB(90, 255, 140, 0)),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Ej: BCHIP123456',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 37, 37, 37),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(197, 255, 123, 0),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Botón Buscar Manual
                          BullyYellowButton(
                            icon: Icons.qr_code_scanner,
                            label: 'Buscar',
                            onTap: () async {
                              if (_searchController.text.trim().isEmpty) return;
                              setState(() => _isSearching = true);

                              final nfcRemoteDataSource = NfcRemoteDataSource();
                              final response = await nfcRemoteDataSource.fetchDogInfoByUid(_searchController.text.trim());

                              if (response != null && response.data != null) {
                                final dogSearch = response.data!;
                                setState(() => _isSearching = false);
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsDogs(dog: dogSearch),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _isScanning
                                ? Container(
                                    key: const ValueKey('scanEffect'),
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141414),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFF333333)),
                                    ),
                                    child: Column(
                                      children: [
                                        const LinearProgressIndicator(
                                          minHeight: 4,
                                          backgroundColor: Color(0xFF1A1A1A),
                                          valueColor: AlwaysStoppedAnimation(Color(0xFFFF8C00)),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.nfc, color: Color(0xFFFF8C00), size: 16),
                                            SizedBox(width: 8),
                                            Text(
                                              'Escaneando chip...',
                                              style: TextStyle(color: Colors.white70, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _isSearching
                                ? Container(
                                    key: const ValueKey('scanEffect'),
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141414),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFF333333)),
                                    ),
                                    child: Column(
                                      children: [
                                        const LinearProgressIndicator(
                                          minHeight: 4,
                                          backgroundColor: Color(0xFF1A1A1A),
                                          valueColor: AlwaysStoppedAnimation(Color(0xFFFF8C00)),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.nfc, color: Color(0xFFFF8C00), size: 16),
                                            SizedBox(width: 8),
                                            Text(
                                              'Buscando bully...',
                                              style: TextStyle(color: Colors.white70, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Flujo modular y limpio para el escaneo automático por hardware NFC
  Future<void> _startNfcScanWorkflow(TextEditingController searchController) async {
    setState(() => _isScanning = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sensor NFC Activo. Acerque el chip del canino.')),
    );

    try {
      // 1. Escaneo físico del chip
      NFCTag? tag = await _nfcService.readNfcTag();

      if (tag != null) {
        // Formatear el UID del chip
        final formattedId = tag.id.replaceAllMapped(RegExp(r'.{2}'), (match) => '${match.group(0)}:');
        final savedId = formattedId.endsWith(':') ? formattedId.substring(0, formattedId.length - 1) : formattedId;
        searchController.text = savedId; // Actualizamos el campo de búsqueda con el UID detectado
        print('Chip detectado: $savedId');

        setState(() {
          globals.nfcSerialNumbers = savedId;
          globals.lastScannedSerial = savedId;
        });

        // 2. Consultar la API usando el UID real obtenido del chip físico
        final nfcRemoteDataSource = NfcRemoteDataSource();
        final response = await nfcRemoteDataSource.fetchDogInfoByUid(savedId);

        if (response != null && response.data != null) {
          final dogSearch = response.data!;
          
          if (!mounted) return;
          
          // 3. Éxito: Navegar a los detalles
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsDogs(dog: dogSearch),
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡Lectura Exitosa! Chip: $savedId')),
          );
        } else {
          throw Exception("Código de chip detectado pero no registrado en el sistema.");
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }
}