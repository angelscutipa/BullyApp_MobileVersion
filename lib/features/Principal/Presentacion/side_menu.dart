import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:bully_app/core/global_variables.dart';
import 'package:bully_app/features/auth/data/datasources/login_remote_data_source.dart';
import 'package:bully_app/features/auth/data/models/login_response_model.dart';

class SideMenu extends StatefulWidget {
  final InAppWebViewController? controller;
  final String btnTextLogin;

  const SideMenu({
    super.key,
    required this.controller,
    required this.btnTextLogin,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool _isComunidadExpanded = false;

  void _navigateTo(String url) {
    widget.controller?.loadUrl(
      urlRequest: URLRequest(url: WebUri(url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        color: const Color(0xFF1A1A1A),
        child: Column(
          children: [
            // Header con botón de cerrar
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mas opciones',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Botón Iniciar Sesión
                  GestureDetector(
                    onTap: () async {
                      showGlobalAppBar = true;
                      /*final loginRemoteDataSource = AuthRemoteDataSource();
                      final loginModel = await loginRemoteDataSource.login(
                        email: 'angels.cutipasamayani@gmail.com',
                        password: 'mFb43TADKUVuyCu@',
                      );*/
                      _navigateTo('https://bullyapp.com.pe/login');
                      Navigator.of(context).pop();
                      debugPrint('Iniciar Sesión pulsado');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1419),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF2A2A2A),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.login,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.btnTextLogin,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const SizedBox(height: 24),

                  // NFC
                  _buildMenuItem(
                    icon: Icons.nfc,
                    title: 'Bullychip',
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),

                  // Dogs
                  _buildMenuItem(
                    icon: Icons.pets,
                    title: 'Dogs',
                    onTap: () {
                      showGlobalAppBar = false;
                      _navigateTo('https://bullyapp.com.pe/bullys');
                      Navigator.of(context).pop();
                    },
                  ),

                  // Torneos
                  _buildMenuItem(
                    icon: Icons.emoji_events,
                    title: 'Torneos',
                    onTap: () {
                      showGlobalAppBar = false;
                      _navigateTo('https://bullyapp.com.pe/events');
                      Navigator.of(context).pop();
                    },
                  ),

                  // Ruta Bulls
                  _buildMenuItem(
                    icon: Icons.route,
                    title: 'Ruta Bulls',
                    onTap: () {
                      showGlobalAppBar = false;
                      _navigateTo('https://bullyapp.com.pe/blog');
                      Navigator.of(context).pop();
                    },
                  ),

                  // IDRB
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: 'IDRB',
                    onTap: () {
                      showGlobalAppBar = false;
                      _navigateTo('https://bullyapp.com.pe/idrb');
                      Navigator.of(context).pop();
                    },
                  ),

                  // Tienda
                  _buildMenuItem(
                    icon: Icons.store_outlined,
                    title: 'Tienda',
                    onTap: () {
                      showGlobalAppBar = false;
                      _navigateTo('https://bullyapp.com.pe/marketplace');
                      Navigator.of(context).pop();
                    },
                  ),

                  // Comunidad (con submenú)
                  _buildExpandableMenuItem(
                    icon: Icons.people_outline,
                    title: 'Comunidad',
                    isExpanded: _isComunidadExpanded,
                    onToggle: () {
                      setState(() {
                        _isComunidadExpanded = !_isComunidadExpanded;
                      });
                    },
                    children: [
                      _buildSubMenuItem(
                        icon: Icons.person_outline,
                        title: 'Propietario',
                        onTap: () {
                          _navigateTo('https://bullyapp.com.pe/owners');
                          Navigator.of(context).pop();
                        },
                      ),
                      _buildSubMenuItem(
                        icon: Icons.groups,
                        title: 'Teams',
                        onTap: () {
                          _navigateTo('https://bullyapp.com.pe/teams');
                          Navigator.of(context).pop();
                        },
                      ),
                      _buildSubMenuItem(
                        icon: Icons.home_outlined,
                        title: 'Criaderos',
                        onTap: () {
                          _navigateTo('https://bullyapp.com.pe/kennels');
                          Navigator.of(context).pop();
                        },
                      ),
                      _buildSubMenuItem(
                        icon: Icons.business_outlined,
                        title: 'Negocios',
                        onTap: () {
                          _navigateTo('https://bullyapp.com.pe/businesses');
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white70,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableMenuItem({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white70,
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Comunidad',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded) ...children,
        ],
      ),
    );
  }

  Widget _buildSubMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, left: 40),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}