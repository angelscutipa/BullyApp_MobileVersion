import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/onboarding_item.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'package:bully_app/core/global_variables.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Colores personalizados del diseño premium (Naranja/Dorado de la referencia)
  static const Color brandOrange = Color(0xFFFF8C00);
  static const Color brandYellow = Color(0xFFFFA500);
  static const Color itemBackground = Color(0xFF1E1E20);
  static const Color textMuted = Color(0xAAFFFFFF);

  late final List<OnboardingItem> _items;

  @override
  void initState() {
    super.initState();
    _items = _buildOnboardingItems();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    showGlobalAppBar = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomePage(title: 'Bully App Home'),
        ),
      );
    }
  }

  List<OnboardingItem> _buildOnboardingItems() {
    return [
      OnboardingItem(
        badgeText: 'LA COMUNIDAD BULLY #1',
        titlePrefix: 'Bienvenido al\necosistema global de\nperros de raza ',
        highlightedText: '',
        titleSuffix: '',
        features: const [
          OnboardingFeature(icon: Icons.workspace_premium_outlined, title: 'Pedigrí\nVerificado'),
          OnboardingFeature(icon: Icons.public_rounded, title: 'Comunidad\nGlobal'),
          OnboardingFeature(icon: Icons.shield_rounded, title: 'Seguridad\nBullyChip'),
        ],
        centerWidget: const _DogWelcomeGraphic(),
      ),
      OnboardingItem(
        badgeText: 'CERTIFICACIÓN OFICIAL & TRÁMITES 100% DIGITALES',
        titlePrefix: 'Formaliza y protege el linaje\nde tu ejemplar con ',
        highlightedText: 'IDBR',
        titleSuffix: '',
        features: const [
          OnboardingFeature(icon: Icons.qr_code_2_rounded, title: 'Pedigrí Digital Inmutable'),
          OnboardingFeature(icon: Icons.language_rounded, title: 'Homologación Internacional'),
          OnboardingFeature(icon: Icons.swap_horiz_rounded, title: 'Transferencia de propiedad'),
        ],
        tags: const ['WEB3', 'GLOBAL', 'GEN 5'],
        footerLockText: 'Registro respaldado bajo estándares IDBR Global',
        centerWidget: const _IdbrCenterGraphic(),
      ),
      OnboardingItem(
        badgeText: 'TECNOLOGÍA BULLYCHIP',
        titlePrefix: 'Identificación inteligente y ',
        highlightedText: 'blindaje total',
        titleSuffix: ' con BullyChip',
        features: const [
          OnboardingFeature(icon: Icons.qr_code_scanner_rounded, title: 'Escaneo Instantáneo'),
          OnboardingFeature(icon: Icons.notifications_none_rounded, title: 'Perfil y Alertas'),
          OnboardingFeature(icon: Icons.verified_user_outlined, title: 'Ejemplar Verificado'),
        ],
        centerWidget: const _NfcCenterGraphic(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // Barra Superior (Header)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón Atrás o Icono App
                  _currentPage > 0
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        )
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: textMuted),
                        ),
                  // Título e Icono Central de la App cambiante dinámicamente si es IDBR
                  Row(
                    children: [
                      _currentPage == 1 
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: brandOrange.withOpacity(0.3))
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.shield_outlined, color: brandYellow, size: 14),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'IDBR',
                                    style: TextStyle(
                                      color: brandYellow,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              children: [
                                Icon(Icons.shield, color: brandYellow, size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  'BullyApp',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                  // Botón Saltar
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Saltar',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido deslizable (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Gráfico central
                        SizedBox(
                          height: 200,
                          child: item.centerWidget,
                        ),
                        const SizedBox(height: 24),

                        // Badge / Etiqueta de tecnología
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: brandOrange.withOpacity(0.4), width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                            color: brandOrange.withOpacity(0.05),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: brandOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.badgeText,
                                style: const TextStyle(
                                  color: brandYellow,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Título Principal con Texto Resaltado
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            children: [
                              TextSpan(text: item.titlePrefix),
                              TextSpan(
                                text: item.highlightedText,
                                style: const TextStyle(color: brandOrange),
                              ),
                              TextSpan(text: item.titleSuffix),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Lista de Características (Features)
                        index == 0
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: item.features.map((feature) {
                                  return Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: itemBackground,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(feature.icon, color: brandYellow, size: 24),
                                          const SizedBox(height: 12),
                                          Text(
                                            feature.title.toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            : Column(
                                children: List.generate(item.features.length, (fIndex) {
                                  final feature = item.features[fIndex];
                                  final hasTag = item.tags != null && item.tags!.length > fIndex;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: itemBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: brandOrange.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: brandOrange.withOpacity(0.2)),
                                          ),
                                          child: Icon(feature.icon, color: brandYellow, size: 20),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            feature.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (hasTag)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item.tags![fIndex],
                                              style: TextStyle(
                                                color: brandYellow.withOpacity(0.8),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                        if (item.footerLockText != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline_rounded, color: brandYellow.withOpacity(0.6), size: 14),
                              const SizedBox(width: 8),
                              Text(
                                item.footerLockText!,
                                style: TextStyle(
                                  color: textMuted.withOpacity(0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Parte Inferior: Indicador, Botón y Link de Login
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicador de Páginas (Puntitos/Rayas personalizados)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_items.length, (index) {
                      final isSelected = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 4,
                        width: isSelected ? 22 : 8,
                        decoration: BoxDecoration(
                          color: isSelected ? brandOrange : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Botones Inferiores de Acción (Atrás y Siguiente)
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              color: const Color(0xFF1E1E20),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: OutlinedButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Atrás',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              colors: [brandOrange, brandYellow],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: brandOrange.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage < _items.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _completeOnboarding();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _items.length - 1
                                      ? 'Comenzar Ahora'
                                      : 'Siguiente',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Texto de Iniciar Sesión inferior o espaciado si se requiere
                  if (_currentPage == _items.length - 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes cuenta? ',
                          style: TextStyle(color: textMuted, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: _completeOnboarding,
                          child: const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              color: brandYellow,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget premium para simular el perro de bienvenida y el badge Bullychip v2.4
class _DogWelcomeGraphic extends StatelessWidget {
  const _DogWelcomeGraphic();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
            )
          ]
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Silueta / Reemplazo elegante de imagen con Icono de perro premium si no hay asset
            Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.pets_rounded,
                size: 130,
                color: const Color(0xFFFF8C00),
              ),
            ),
            // Mensaje de la foto o texto representativo del perro
            Positioned(
              top: 40,
              child: Column(
                children: [
                  Icon(Icons.shield_outlined, color: const Color(0xFFFF8C00).withOpacity(0.6), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    "RAZA BULLY",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2
                    ),
                  )
                ],
              ),
            ),
            // El mini banner inferior: BULLYCHIP NFC V2.4
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.15))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF8C00),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'BULLYCHIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Widget premium para el gráfico central de IDBR con el escudo y marcas de enfoque
class _IdbrCenterGraphic extends StatelessWidget {
  const _IdbrCenterGraphic();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Aura de luz naranja de fondo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8C00).withOpacity(0.15),
                  blurRadius: 40,
                  spreadRadius: 5,
                )
              ]
            ),
          ),
          // El contenedor del escudo con las marcas de las esquinas
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5)
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Marcas de enfoque en las esquinas (Corner brackets)
                ..._buildCornerMarkers(),
                // Escudo central con check
                const Icon(Icons.verified_user_rounded, color: Color(0xFFFFA500), size: 42),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    const double length = 8.0;
    const double thickness = 1.5;
    const Color markerColor = Color(0xFFFFA500);
    
    return [
      // Top Left
      Positioned(top: 8, left: 8, child: _CornerMarker(length: length, thickness: thickness, isTop: true, isLeft: true, color: markerColor)),
      // Top Right
      Positioned(top: 8, right: 8, child: _CornerMarker(length: length, thickness: thickness, isTop: true, isLeft: false, color: markerColor)),
      // Bottom Left
      Positioned(bottom: 8, left: 8, child: _CornerMarker(length: length, thickness: thickness, isTop: false, isLeft: true, color: markerColor)),
      // Bottom Right
      Positioned(bottom: 8, right: 8, child: _CornerMarker(length: length, thickness: thickness, isTop: false, isLeft: false, color: markerColor)),
    ];
  }
}

class _CornerMarker extends StatelessWidget {
  final double length;
  final double thickness;
  final bool isTop;
  final bool isLeft;
  final Color color;

  const _CornerMarker({required this.length, required this.thickness, required this.isTop, required this.isLeft, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        children: [
          Positioned(
            top: isTop ? 0 : null,
            bottom: !isTop ? 0 : null,
            left: 0,
            right: 0,
            child: Container(height: thickness, color: color),
          ),
          Positioned(
            left: isLeft ? 0 : null,
            right: !isLeft ? 0 : null,
            top: 0,
            bottom: 0,
            child: Container(width: thickness, color: color),
          ),
        ],
      ),
    );
  }
}

// Widget genérico para gráficos centrales de pantallas 1 y 2

class _CenterGraphicWidget extends StatelessWidget {
  final IconData icon;
  final int pulseCount;

  const _CenterGraphicWidget({
    required this.icon,
    required this.pulseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(pulseCount, (index) {
            final radius = 60.0 + (index * 35.0);
            return Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF8C00).withOpacity(0.08 / (index + 1)),
                  width: 1.5,
                ),
              ),
            );
          }),
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF8C00).withOpacity(0.1),
              border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.2)),
            ),
            child: Icon(icon, color: const Color(0xFFFFA500), size: 36),
          ),
        ],
      ),
    );
  }
}

// Widget premium para simular la pantalla NFC Contactless de la captura
class _NfcCenterGraphic extends StatelessWidget {
  const _NfcCenterGraphic();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 4 puntos guía exteriores
          ...[
            const Positioned(top: 0, child: _SmallDot()),
            const Positioned(bottom: 0, child: _SmallDot()),
            const Positioned(left: 0, child: _SmallDot()),
            const Positioned(right: 0, child: _SmallDot()),
          ],
          // Anillos concéntricos exteriores
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.15), width: 1),
            ),
          ),
          Container(
            width: 135,
            height: 135,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.25), width: 1.5),
            ),
          ),
          // Núcleo central naranja brillante con ondas NFC
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFF9F00), Color(0xFFFF6F00)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8C00).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.contactless_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallDot extends StatelessWidget {
  const _SmallDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Color(0xFFFFA500),
        shape: BoxShape.circle,
      ),
    );
  }
}
