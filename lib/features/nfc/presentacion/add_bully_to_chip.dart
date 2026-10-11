import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:bully_app/core/global_variables.dart' as globals;
import 'package:bully_app/core/services/nfc_services.dart';

import 'package:bully_app/features/NFC/data/datasources/chip_remote_data_source.dart';
import 'package:bully_app/features/NFC/data/datasources/link_chip_remote_data_source.dart';
import 'package:bully_app/features/nfc/presentacion/fingerprint_pulse.dart';

import 'Widget/chip_status_card.dart';

class AddBullyToChip {
  const AddBullyToChip._();

  /// Muestra la pantalla completa de vinculación de chip
  static Future<void> mostrarDialogo(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddBullyToChipScreen(),
      ),
    );
  }

  static Future<void> mostrarPantalla(BuildContext context) {
    return mostrarDialogo(context);
  }
}

class AddBullyToChipScreen extends StatefulWidget {
  const AddBullyToChipScreen({super.key});

  @override
  State<AddBullyToChipScreen> createState() => _AddBullyToChipScreenState();
}

class _AddBullyToChipScreenState extends State<AddBullyToChipScreen> {
  final _codigoController = TextEditingController();
  final NfcService _nfcService = NfcService();

  ChipStatus _chipStatus = ChipStatus.noBuscado;

  int chip_id = -3;

  // Variables para almacenar dinámicamente la información del chip detectado
  String _scannedCode = '';
  String _scannedSerial = '';

  bool _isScanning = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _codigoController.dispose();
    FlutterNfcKit.finish();
    super.dispose();
  }

  /// Renderiza dinámicamente la tarjeta según el estado actual devuelto por la API
  Widget _buildStatusCard() {
    switch (_chipStatus) {
      case ChipStatus.noEncontrado:
        return ChipStatusCard(
          status: ChipStatus.noEncontrado,
          code: _scannedCode.isEmpty ? 'N/A' : _scannedCode,
          serial: _scannedSerial,
        );
      case ChipStatus.ocupado:
        return ChipStatusCard(
          status: ChipStatus.ocupado,
          code: _scannedCode,
          serial: _scannedSerial,
        );
      case ChipStatus.disponible:
        return ChipStatusCard(
          status: ChipStatus.disponible,
          code: _scannedCode,
          serial: _scannedSerial,
        );
      case ChipStatus.noBuscado:
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131517),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131517),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF26190E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF5C2D0C)),
              ),
              child: const Icon(
                Icons.developer_board,
                color: Color(0xFFFF6900),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Vincular Chip de Identificación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2226),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF26282B)),
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF8E95A2),
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Cerrar',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- INSTRUCCIONES ---
              const Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: 'Busca por correlativo, código físico o escanea por NFC para vincularlo a ',
                    style: TextStyle(color: Color(0xFF7A828E)),
                  ),
                  TextSpan(
                    text: 'Doki',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '.',
                    style: TextStyle(color: Color(0xFF7A828E)),
                  ),
                ]),
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),

              // --- BLOQUE ESCANEO NFC ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF181A1D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF26282B)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.nfc_rounded,
                      color: Color(0xFFFF6900),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Escaneo NFC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Acerque el chip NFC al dispositivo para escanearlo automáticamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF7A828E),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isScanning
                            ? null
                            : () => _startNfcScanWorkflow(_codigoController),
                        icon: const Icon(Icons.search_rounded, size: 20),
                        label: const Text(
                          'Iniciar escaneo',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6900),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- SEPARADOR ---
              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFF26282B))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'O BUSCA POR CÓDIGO',
                      style: TextStyle(
                        color: Color(0xFF525866),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFF26282B))),
                ],
              ),
              const SizedBox(height: 24),

              // --- CAMPO DE BÚSQUEDA MANUAL ---
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codigoController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF525866),
                          size: 20,
                        ),
                        hintText: 'Correlativo o código físico...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF525866),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF181A1D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF26282B)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF26282B)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFFF6900)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSearching
                          ? null
                          : () => _searchByCodeManual(_codigoController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26282B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFF6900),
                              ),
                            )
                          : const Text('Buscar'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- TARJETA DE ESTADO DINÁMICA ---
              _buildStatusCard(),

              const SizedBox(height: 32),

              // --- ACCIONES ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8E95A2),
                        side: const BorderSide(color: Color(0xFF26282B)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancelar', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _chipStatus == ChipStatus.disponible
                          ? () => _vincularChip(chip_id.toString())
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6900),
                        disabledBackgroundColor: const Color(0xFF26282B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Vincular chip',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Método modular para procesar y mapear la respuesta remota
  void _processChipResponse(dynamic response, String serialUsed) {
    _scannedSerial = serialUsed;

    if (response == null || response.status == null || response.chip == null) {
      _chipStatus = ChipStatus.noEncontrado;
      _scannedCode = '';
      return;
    }

    // Se extrae la información del modelo devuelto por la API
    _scannedCode = response.chip!.code ?? 'Sin código';
    final estado = response.chip!.status;

    if (estado == 'used') {
      _chipStatus = ChipStatus.ocupado;
    } else if (estado == 'available') {
      _chipStatus = ChipStatus.disponible;
      chip_id = response.chip!.id;
    } else {
      _chipStatus = ChipStatus.noEncontrado;
    }
  }

  /// Flujo de escaneo NFC con Pop-up modal y mensajes dinámicos
  Future<void> _startNfcScanWorkflow(TextEditingController searchController) async {
    setState(() {
      _isScanning = true;
    });

    final ValueNotifier<UnlockState> dialogStateNotifier = ValueNotifier(UnlockState.scanning);
    final ValueNotifier<String> dialogMessageNotifier = ValueNotifier('Sensor NFC Activo. Acerque el chip del canino.');

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: const Color(0xFF131517),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF26282B)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Escaneando Chip NFC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<UnlockState>(
                    valueListenable: dialogStateNotifier,
                    builder: (context, currentState, child) {
                      return FingerprintPulseUnlock(
                        state: currentState,
                        size: 140.0,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<String>(
                    valueListenable: dialogMessageNotifier,
                    builder: (context, currentMessage, child) {
                      return Text(
                        currentMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: dialogStateNotifier.value == UnlockState.error
                              ? Colors.redAccent
                              : dialogStateNotifier.value == UnlockState.success
                                  ? Colors.greenAccent
                                  : const Color(0xFF7A828E),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        FlutterNfcKit.finish();
                        Navigator.of(dialogContext).pop();
                      },
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      label: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      NFCTag? tag = await _nfcService.readNfcTag();

      if (tag != null) {
        final formattedId = tag.id.replaceAllMapped(
          RegExp(r'.{2}'),
          (match) => '${match.group(0)}:',
        );
        final savedId = formattedId.endsWith(':')
            ? formattedId.substring(0, formattedId.length - 1)
            : formattedId;

        searchController.text = savedId;

        globals.nfcSerialNumbers = savedId;
        globals.lastScannedSerial = savedId;

        final nfcRemoteDataSource = ChipRemoteDataSource();
        final response = await nfcRemoteDataSource.searchChip(savedId);

        if (!mounted) return;

        _processChipResponse(response, savedId);

        if (_chipStatus != ChipStatus.noBuscado && _chipStatus != ChipStatus.noEncontrado) {
          dialogStateNotifier.value = UnlockState.success;
          dialogMessageNotifier.value = '¡Chip encontrado! (${_chipStatus == ChipStatus.disponible ? "Disponible" : "Ocupado"})';
        } else {
          dialogStateNotifier.value = UnlockState.error;
          dialogMessageNotifier.value = 'Chip no registrado o no encontrado.';
        }

        await Future.delayed(const Duration(milliseconds: 1500));

        if (!mounted) return;
        Navigator.of(context).pop(); // Cerrar diálogo
        setState(() {});
      } else {
        throw Exception("No se detectó ningún chip.");
      }
    } catch (error) {
      dialogStateNotifier.value = UnlockState.error;
      dialogMessageNotifier.value = 'Error de lectura de Bullychip, asegurate de tener encendido el NFC de tu dispositivo';

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;
      Navigator.of(context).pop(); // Cerrar diálogo
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  /// Búsqueda manual por código escrito
  Future<void> _searchByCodeManual(String code) async {
    if (code.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final nfcRemoteDataSource = ChipRemoteDataSource();
      final response = await nfcRemoteDataSource.searchChip(code);

      if (!mounted) return;

      setState(() {
        _processChipResponse(response, code);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  /// Confirmación de vinculación
  void _vincularChip(String chipID) {
    // Se envía a la API la orden para asociar el chip a la mascota
    final nfcRemoteDataSource = LinkChipRemoteDataSource();
    final _response = nfcRemoteDataSource.linkChipToAnimal(chipId: chipID);
    print("VALIDAR VINCULACION: " + _response.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chip vinculado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }
}
