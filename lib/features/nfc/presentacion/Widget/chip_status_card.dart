import 'package:flutter/material.dart';

/// Enum para definir los posibles estados del Chip
enum ChipStatus {
  disponible,
  noEncontrado,
  ocupado,
  noBuscado,
}

class ChipStatusCard extends StatelessWidget {
  final ChipStatus status;
  final String? code;
  final String? serial;

  const ChipStatusCard({
    super.key,
    required this.status,
    this.code,
    this.serial,
  });

  @override
  Widget build(BuildContext context) {
    // Definición de configuraciones visuales según el estado
    final Map<ChipStatus, _StatusConfig> configs = {
      ChipStatus.disponible: _StatusConfig(
        title: 'CHIP ENCONTRADO',
        badgeText: 'Disponible',
        badgeIcon: Icons.check,
        bgColor: const Color(0x803C6F52),
        borderColor: const Color(0xFF3F8C6A),
        titleColor: const Color(0xFF9AE4B8),
        serialColor: const Color(0xFFB5DCC7),
        badgeBgColor: const Color(0xFF102F1F),
        badgeBorderColor: const Color(0xFF5EC58D),
        badgeTextColor: const Color(0xFF9AE4B8),
        badgeIconColor: const Color(0xFF5EC58D),
      ),
      ChipStatus.noEncontrado: _StatusConfig(
        title: 'CHIP NO ENCONTRADO',
        badgeText: 'No encontrado',
        badgeIcon: Icons.close,
        bgColor: const Color(0x806F3C3C),
        borderColor: const Color(0xFF8C3F3F),
        titleColor: const Color(0xFFE49A9A),
        serialColor: const Color(0xFFDCB5B5),
        badgeBgColor: const Color(0xFF2F1010),
        badgeBorderColor: const Color(0xFFC55E5E),
        badgeTextColor: const Color(0xFFE49A9A),
        badgeIconColor: const Color(0xFFC55E5E),
      ),
      ChipStatus.ocupado: _StatusConfig(
        title: 'CHIP ENCONTRADO',
        badgeText: 'Ocupado',
        badgeIcon: Icons.warning_amber_rounded,
        bgColor: const Color(0x806F563C),
        borderColor: const Color(0xFF8C693F),
        titleColor: const Color(0xFFE4C49A),
        serialColor: const Color(0xFFDCD0B5),
        badgeBgColor: const Color(0xFF2F2110),
        badgeBorderColor: const Color(0xFFC5955E),
        badgeTextColor: const Color(0xFFE4C49A),
        badgeIconColor: const Color(0xFFC5955E),
      ),
    };

    final config = configs[status]!;

    // Si no se encuentra, mostramos valores genéricos
    final isNotFound = status == ChipStatus.noEncontrado;
    final displayCode = isNotFound ? '---' : (code ?? 'Sin código');
    final displaySerial = isNotFound ? 'Serial: N/A' : 'Serial: ${serial ?? 'N/A'}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: TextStyle(
                    color: config.titleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  displayCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  displaySerial,
                  style: TextStyle(
                    color: config.serialColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: config.badgeBgColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: config.badgeBorderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  config.badgeIcon,
                  color: config.badgeIconColor,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  config.badgeText,
                  style: TextStyle(
                    color: config.badgeTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class interno para almacenar estilos según el estado
class _StatusConfig {
  final String title;
  final String badgeText;
  final IconData badgeIcon;
  final Color bgColor;
  final Color borderColor;
  final Color titleColor;
  final Color serialColor;
  final Color badgeBgColor;
  final Color badgeBorderColor;
  final Color badgeTextColor;
  final Color badgeIconColor;

  _StatusConfig({
    required this.title,
    required this.badgeText,
    required this.badgeIcon,
    required this.bgColor,
    required this.borderColor,
    required this.titleColor,
    required this.serialColor,
    required this.badgeBgColor,
    required this.badgeBorderColor,
    required this.badgeTextColor,
    required this.badgeIconColor,
  });
}