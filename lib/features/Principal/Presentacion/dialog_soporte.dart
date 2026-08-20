import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SoporteDialog extends StatelessWidget {
  const SoporteDialog({super.key});
  static Future<void> openEmail({
    required String email,
    String subject = 'Soporte App',
    String body = 'Hola, necesito ayuda con...',
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint('No se pudo abrir la aplicación de correo electrónico.');
    }
  }

  /// Abre un chat de WhatsApp con un número (formato internacional sin el símbolo +)
  static Future<void> openWhatsApp({
    required String phoneNumber,
    String message = 'Hola, vengo desde la aplicación móvil.',
  }) async {
    // Es vital codificar el texto para evitar que espacios o caracteres especiales rompan la URL
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber?text=$encodedMessage');

    // Usamos LaunchMode.externalApplication para forzar a que salga de la app hacia WhatsApp
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint('No se pudo abrir WhatsApp.');
    }
  }

  /// Abre el marcador telefónico del sistema listo para llamar
  static Future<void> openPhoneCall({required String phoneNumber}) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('No se pudo abrir el marcador de llamadas.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 14, 14, 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color.fromARGB(255, 43, 43, 43),
          width: 2,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24), // Márgenes mínimos
      child: SizedBox(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y botón de cerrar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Soporte BullyApp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Descripción
              const Text(
                '¿Necesitas ayuda para activar tu chip o usar la plataforma BullyApp? Aquí puedes solicitar soporte directo para BullyChip y resolver dudas rápidamente.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Subtítulo
              const Text(
                'Selecciona el canal que prefieras para recibir soporte:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              
              // Opción Correo
              _buildContactOption(
                icon: Icons.email_outlined,
                iconColor: Colors.yellow[700]!,
                title: 'Correo',
                subtitle: 'soporte@bullyapp.com.pe',
                onTap: () {
                  // Lógica para enviar correo
                  openEmail(
                    email: 'soporte@bullyapp.com.pe',
                  );
                },
              ),
              const SizedBox(height: 12),
              
              // Opción WhatsApp
              _buildContactOption(
                icon: Icons.chat_bubble_outline,
                iconColor: Colors.green,
                title: 'WhatsApp',
                subtitle: '+51 997 612 277',
                onTap: () {
                  // Lógica para abrir WhatsApp
                  openWhatsApp(
                    phoneNumber: '51997612277', // Código de país + número (ejemplo Perú)
                    message: 'Hola, tengo una consulta sobre el aplicativo.',
                  );
                },
              ),
              const SizedBox(height: 12),
              
              // Opción Llamada
              _buildContactOption(
                icon: Icons.phone_outlined,
                iconColor: Colors.cyan,
                title: 'Llamada',
                subtitle: '+51 997 612 277',
                onTap: () {
                  // Lógica para hacer llamada
                  openPhoneCall(
                    phoneNumber: '+51997612277', // El marcador telefónico acepta el símbolo +
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 27, 27, 27),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}