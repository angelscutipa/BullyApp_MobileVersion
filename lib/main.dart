import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'features/Principal/Presentacion/menu_footer.dart';
import 'features/Principal/Presentacion/side_menu.dart';
import 'features/Principal/menu_web_view.dart';

import 'core/global_variables.dart';

void main() {
  // Asegura la inicialización de los bindings antes de configurar SystemChrome
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF151517), // Ajustado al fondo oscuro de la app
      statusBarIconBrightness: Brightness.light, // Iconos blancos
      statusBarBrightness: Brightness.dark, // Para consistencia en iOS
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bully App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, // Define el tema base como oscuro
        ),
      ),
      home: const MyHomePage(title: 'Bully App Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController controller;
  bool _hasError = false; 
  bool _isLoading = true; 
  final String _targetUrl = 'https://bullyapp.com.pe/';

  String _buttonText = "Iniciar Sesión";

  bool _showFab = false;
  
  // O una bandera booleana si prefieres
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..addJavaScriptChannel(
      //   'NfcChannel',
      //   onMessageReceived: (JavaScriptMessage message) {
      //     if (message.message == 'OPEN_NFC_DIALOG') {
      //       _showNfcDialog(); // Llama al Dialog nativo
      //     }
      //   },
      // )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            setState(() {
              _hasError = false; 
              _isLoading = true;  

              if (url.contains('/dashboard')) {
                _isLoggedIn = true;
                _buttonText = "Resumen";
              } else if (url.contains('/login') || url.contains('/logout')) {
                _isLoggedIn = false;
                _buttonText = "Iniciar Sesión";
              }

            });
          },

          onUrlChange: (UrlChange change) {
            if (!mounted || change.url == null) return;
            
            final url = change.url!;
            print("🔄 Cambio de URL detectado: $url");

            // Detectar si estamos en /management/animals/{número}
            final shouldShowFab = _esUrlDeAnimalEspecifico(url);
            
            if (shouldShowFab != _showFab) {
              setState(() {
                _showFab = shouldShowFab;
              });
              print("🎯 FAB visible: $_showFab");
            }

            if (url.contains('/management/animals')) {
              print("✅ Estamos en animals, ejecutando limpieza...");
              _inyectarEstiloAntiReact();
            }
          },


          onPageFinished: (String url) {
            setState(() {
              _isLoading = false; 
              _showFab = _esUrlDeAnimalEspecifico(url);
            });

            // 1. Inyección para bloquear zoom táctil
            controller.runJavaScript('''
              if (!document.querySelector('meta[name="viewport"]')) {
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                document.getElementsByTagName('head')[0].appendChild(meta);
              }
            ''');
            
            // 2. Inyección optimizada para remover botón "Descargar App"
            controller.runJavaScript(r'''
              (() => {
                function removeButton() {
                  document.querySelectorAll('button').forEach(btn => {
                    if (btn.textContent && btn.textContent.includes('Descargar App')) {
                      btn.remove();
                    }
                  });
                }
                removeButton();
                
                if (document.body) {
                  const observer = new MutationObserver(removeButton);
                  observer.observe(document.body, {
                    childList: true,
                    subtree: true
                  });
                }
              })();
            ''');
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {
            // Validación robusta de pérdida de conexión de red
            if (error.errorCode == -2 || 
                error.errorCode == -1009 || 
                error.description.contains('ERR_INTERNET_DISCONNECTED') ||
                error.description.contains('ERR_NAME_NOT_RESOLVED')) {
              setState(() {
                _hasError = true;
                _isLoading = false; 
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_targetUrl));
  }

  void _retryConnection() {
    setState(() {
      _hasError = false;
      _isLoading = true; 
    });
    controller.loadRequest(Uri.parse(_targetUrl));
  }

  void _inyectarEstiloAntiReact() {
    const String cssInjection = r'''
      (function() {
        // 1. Evitamos inyectar múltiples etiquetas style si la función se llama varias veces
        if (document.getElementById('anti-react-nfc-style')) return;

        // 2. Creamos una etiqueta <style> y la inyectamos en el <head>
        const style = document.createElement('style');
        style.id = 'anti-react-nfc-style';
        
        // 3. Usamos !important en TODAS las propiedades para que React no pueda sobrescribirlo
        style.innerHTML = `
          [title*="Vincular chip NFC"],
          [data-title*="Vincular chip NFC"],
          [aria-label*="Vincular chip NFC"],
          button:has([title*="Vincular chip NFC"]),
          button:has([data-title*="Vincular chip NFC"]) {
            display: none !important;
            visibility: hidden !important;
            pointer-events: none !important;
            width: 0 !important;
            height: 0 !important;
            margin: 0 !important;
            padding: 0 !important;
            overflow: hidden !important;
            opacity: 0 !important;
          }
        `;
        
        document.head.appendChild(style);
        console.log("🛡️ Estilo Anti-React inyectado en el HEAD");

        // 4. RED DE SEGURIDAD: MutationObserver ligero
        // Solo vigila si el botón logra aparecer a pesar del CSS (muy raro, pero posible en SPAs agresivas)
        const observer = new MutationObserver(() => {
          const elements = document.querySelectorAll('[title*="Vincular chip NFC"], [data-title*="Vincular chip NFC"]');
          elements.forEach(el => {
            // Si por alguna razón el estilo en línea fue sobrescrito, lo forzamos de nuevo
            if (el.style.display !== 'none') {
              el.style.setProperty('display', 'none', 'important');
              el.style.setProperty('visibility', 'hidden', 'important');
              el.style.setProperty('pointer-events', 'none', 'important');
            }
          });
        });

        observer.observe(document.body, { 
          childList: true, 
          subtree: true,
          attributes: true, // Vigila también cambios en los atributos (como el style)
          attributeFilter: ['style', 'class'] 
        });
        
        // Detenemos el observer después de 10 segundos para ahorrar batería
        setTimeout(() => observer.disconnect(), 10000);
      })();
    ''';

    controller.runJavaScript(cssInjection);
  }

  bool _esUrlDeAnimalEspecifico(String url) {
  // Regex: busca /management/animals/ seguido de uno o más dígitos
  // Ejemplos que coinciden:
  // - https://bullyapp.com.pe/management/animals/123
  // - https://bullyapp.com.pe/management/animals/456/edit
  // - https://bullyapp.com.pe/management/animals/789?tab=info
  final regex = RegExp(r'/management/animals/\d+');
  return regex.hasMatch(url);
}

  @override
  Widget build(BuildContext context) {
    // Implementación de PopScope para poder usar el botón 'Atrás' nativo dentro de la navegación web
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await controller.canGoBack()) {
          await controller.goBack();
        } else {
          // Si no puede retroceder en la web, minimiza o cierra la app de forma segura
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF151517), 
        endDrawer: SideMenu(controller: controller, btnTextLogin: _buttonText),
        endDrawerEnableOpenDragGesture: true,
        appBar: showGlobalAppBar 
            ? AppBar(
                backgroundColor: Colors.transparent,
                toolbarHeight: 0,
                elevation: 0,
              )
            : null,
        body: !_hasError 
            ? Stack(
                children: [
                  WebViewSection(controller: controller),
                  if (_isLoading) _buildLoadingWidget(),
                ],
              )
            : _buildNoInternetWidget(),
        bottomSheet: MenuFooter(controller: controller),
        floatingActionButton: _showFab
        ? Padding(
            // Esto empuja el botón hacia arriba sin romper el hit test
            padding: const EdgeInsets.only(bottom: 70), 
            child: FloatingActionButton.extended(
              onPressed: () {
                print("🔘 ¡FAB PRESIONADO!");
                _mostrarDialogoOAccion();
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
          )
        : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // Método de ejemplo para la acción del FAB
  void _mostrarDialogoOAccion() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF131517),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF26282B),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con Icono, Título y Botón de Cierre
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26190E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF5C2D0C),
                          width: 1,
                        ),
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
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close, color: Color(0xFF8E95A2), size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(width: 0, height: 12),
                
                // Descripción
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF7A828E),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: 'Busca por correlativo, código físico o escanea por NFC para vincularlo a ',
                      ),
                      TextSpan(
                        text: 'Doki',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tarjeta NFC No Disponible
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181A1D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF26282B),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF22252A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wifi,
                          color: Color(0xFF525866),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'NFC no disponible',
                        style: TextStyle(
                          color: Color(0xFF8E95A2),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Usa la búsqueda manual por código',
                        style: TextStyle(
                          color: Color(0xFF525866),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Separador con Texto "O BUSCA POR CÓDIGO"
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Color(0xFF26282B),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'O BUSCA POR CÓDIGO',
                        style: TextStyle(
                          color: const Color(0xFF525866).withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Color(0xFF26282B),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campo de Búsqueda y Botón Buscar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF181A1D),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF26282B),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Color(0xFF525866),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Correlativo o código físico...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF525866),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2024),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Color(0xFF26282B),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text(
                          'Buscar',
                          style: TextStyle(
                            color: Color(0xFF8E95A2),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Botones Inferiores: Cancelar y Vincular Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF8E95A2),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6900),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Vincular chip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: const Color(0xFF151517), 
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)), 
              strokeWidth: 3,
            ),
            SizedBox(height: 18),
            Text(
              "Cargando...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 20),
            const Text(
              "¡Uy! Sin conexión a internet",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Por favor verifica tu red e inténtalo de nuevo.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retryConnection,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF151517)),
              label: const Text(
                "Reintentar conexión",
                style: TextStyle(
                  color: Color(0xFF151517),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700), // Dorado corporativo
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNfcDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF151517), // Estética oscura de tu app
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.nfc, color: Color(0xFFFFD700)), // Icono dorado
            SizedBox(width: 10),
            Text(
              "Vincular Chip NFC",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          "Acerque la tarjeta o dispositivo NFC a la parte trasera del teléfono para iniciar la lectura...",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              // Aquí puedes iniciar el escaneo NFC nativo de Flutter
            },
            child: const Text(
              "Escanear",
              style: TextStyle(color: Color(0xFF151517), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
}
