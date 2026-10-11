import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsUtils {
  static Future<void> makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  static Future<void> sendEmail(String? email) async {
    if (email == null || email.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  static Future<void> openMap(String? mapLocation) async {
    if (mapLocation == null || mapLocation.isEmpty) return;
    Uri? uri;
    if (mapLocation.startsWith('http://') || mapLocation.startsWith('https://')) {
      uri = Uri.tryParse(mapLocation);
    } else {
      uri = Uri.tryParse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mapLocation)}');
    }
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static void shareProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartiendo perfil del propietario...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static String formatMicrochip(String? rawChip) {
    if (rawChip == null || rawChip.isEmpty) return 'Sin Microchip';
    if (rawChip.length > 7) {
      return '${rawChip.substring(0, 7)}...';
    }
    return rawChip;
  }

  static String getSexText(String? rawSex) {
    final sex = rawSex ?? '';
    if (sex.toLowerCase().contains('female') || sex.toLowerCase().contains('hembra')) {
      return 'Hembra';
    }
    return 'Macho';
  }

  static bool isMale(String? rawSex) {
    final sex = rawSex ?? '';
    return !sex.toLowerCase().contains('female') && !sex.toLowerCase().contains('hembra');
  }

  static String calculateAge(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '2 Años';

    try {
      DateTime? birthDate = DateTime.tryParse(dateStr);

      if (birthDate == null) {
        final parts = dateStr.split(RegExp(r'[/.-]'));
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            final year = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final day = int.tryParse(parts[2].split(' ')[0]);
            if (year != null && month != null && day != null) {
              birthDate = DateTime(year, month, day);
            }
          } else if (parts[2].length == 4) {
            final day = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final year = int.tryParse(parts[2].split(' ')[0]);
            if (year != null && month != null && day != null) {
              birthDate = DateTime(year, month, day);
            }
          }
        }
      }

      if (birthDate == null) {
        return dateStr;
      }

      final now = DateTime.now();
      if (birthDate.isAfter(now)) return 'Recién nacido';

      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;
      if (now.day < birthDate.day) {
        months--;
      }
      if (months < 0) {
        years--;
        months += 12;
      }

      if (years >= 1) {
        return '$years ${years == 1 ? "Año" : "Años"}';
      } else if (months >= 1) {
        return '$months ${months == 1 ? "Mes" : "Meses"}';
      } else {
        final days = now.difference(birthDate).inDays;
        if (days > 0) {
          return '$days ${days == 1 ? "Día" : "Días"}';
        }
        return 'Recién nacido';
      }
    } catch (_) {
      return dateStr;
    }
  }
}
