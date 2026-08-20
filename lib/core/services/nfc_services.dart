import 'dart:developer';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NfcService {
  Future<NFCTag?> readNfcTag() async {
    try {
      var availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        throw Exception("El NFC no está disponible o está desactivado.");
      }

      log("Buscando etiqueta NFC...");
      
      // Optimizamos agregando un timeout controlado de 10-15 segundos máximo
      NFCTag tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 12),
        iosAlertMessage: "Acerca la tarjeta al lector",
        androidPlatformSound: true, 
        readIso15693: true,
        readIso18092: true,
      );

      log("¡Etiqueta detectada! ID: ${tag.id}");
      
      if (tag.ndefAvailable == true) {
        final ndefRecords = await FlutterNfcKit.readNDEFRecords();
        for (var record in ndefRecords) {
          print("Dato NDEF: ${record.basicInfoString}");
        }
      }

      return tag;
    } catch (e) {
      log("Error leyendo NFC: $e");
      rethrow;
    } finally {
      // Se garantiza el cierre inmediato del canal físico de la antena del smartphone
      await FlutterNfcKit.finish();
    }
  }
}