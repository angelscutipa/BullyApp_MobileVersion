import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:bully_app/features/Principal/Presentacion/dialog_soporte.dart';
import 'package:bully_app/features/nfc/presentacion/bully_chip_search_dialog.dart';

import 'package:bully_app/core/global_variables.dart';

class MenuFooter extends StatefulWidget {
  final WebViewController controller;

  const MenuFooter({super.key, required this.controller });

  @override
  State<MenuFooter> createState() => _MenuFooterState();
}

class _MenuFooterState extends State<MenuFooter> {
  
  // int _selectedIndex = 0;

  // Función utilitaria para cambiar de URL limpiamente
  void _navigateTo(String url) {
    widget.controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tema global configurado en la app para diseño profesional
    // final theme = Theme.of(context);
    
    // Colores personalizados para el footer
    final Color backgroundColor = const Color.fromARGB(255, 21, 21, 23); //theme.cardColor;
    final Color inactiveColor = Colors.grey[600]!;
    final Color activeColor = const Color(0xFFFFD700); // Amarillo/Dorado
    final Color containerColor = Colors.grey[850]!;

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(color: const Color.fromARGB(255, 43, 43, 43), width: 1),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [            
            _buildNavigationBar(activeColor, inactiveColor, containerColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(Color activeColor, Color inactiveColor, Color containerColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.info_outline, 'IDRB', activeColor, inactiveColor, containerColor, "https://bullyapp.com.pe/idrb", false),
          _buildNavItem(Icons.pets, 'Dogs', activeColor, inactiveColor, containerColor, "https://bullyapp.com.pe/bullys", false),
          _buildNavItem(Icons.home_outlined, 'Criaderos', activeColor, inactiveColor, containerColor, "https://bullyapp.com.pe/kennels", false),
          _buildNavItem(Icons.fingerprint, 'BullyChip', activeColor, inactiveColor, containerColor, "", true),
          _buildNavItem(Icons.store_outlined, 'Tienda', activeColor, inactiveColor, containerColor,"https://bullyapp.com.pe/marketplace", false),
          _buildNavItem(Icons.support_outlined, 'Soporte', activeColor, inactiveColor, containerColor, "", false),
          _buildNavItem(Icons.more_horiz, 'Más', activeColor, inactiveColor, containerColor, "", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    Color activeColor,
    Color inactiveColor,
    Color containerColor,
    String url,
    bool isSpecial,
  ) {
    Widget item = GestureDetector(
      onTap: () {

        if(label == 'BullyChip') {
          showDialog(
            context: context,
            builder: (context) => BullyChipSearchDialog(),
          );
        }
        
        else if(label == 'Soporte') {
          showDialog(
            context: context,
            builder: (context) => SoporteDialog(),
          );
        }
        else if(label == 'Más') {
          Scaffold.of(context).openEndDrawer();
        }
        else if (url.isNotEmpty) {
          showGlobalAppBar = false; // Oculta el AppBar global al navegar a una URL externa
          _navigateTo(url);
          debugPrint('Navegar a: $label');
        }
        else {
          debugPrint('Acción para: $label');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono circular o especial
            Container(
              // Aumenta tamaño si es especial
              width: isSpecial ? 48 : 36,
              height: isSpecial ? 48 : 36,
              decoration: BoxDecoration(
                color: isSpecial ? activeColor : containerColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSpecial ? activeColor : Colors.grey[700]!,
                  width: isSpecial ? 2 : 1,
                ),
                boxShadow: isSpecial
                    ? [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isSpecial ? Colors.black : inactiveColor,
                size: isSpecial ? 28 : 18,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                color: isSpecial ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              
            ),
          ],
        ),
      ),
    );

    // Si es especial, sobresalir un poco hacia arriba
    if (isSpecial) {
      return Transform.translate(
        offset: const Offset(0, -20),
        child: item,
      );
    }

    return item;
  }
}

