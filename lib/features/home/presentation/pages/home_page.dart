import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/js_injections.dart';
import '../../../../core/global_variables.dart';
import '../../../../core/storage/auth_local_data_source.dart';
import '../../../../core/utils/permission_manager.dart';
import '../../../../core/utils/url_helper.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/no_internet_view.dart';
import '../../../Principal/Presentacion/menu_footer.dart';
import '../../../Principal/Presentacion/side_menu.dart';
import '../widgets/bully_webview.dart';
import '../widgets/home_fab.dart';
import '../../../animals/data/datasources/animal_remote_data_source.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  InAppWebViewController? webViewController;
  bool _hasError = false;
  bool _isLoading = true;
  bool _isCheckingInitialSession = true;
  String _targetUrl = 'https://bullyapp.com.pe/login';

  String _buttonText = "Iniciar Sesión";
  bool _showFab = false;

  final AuthLocalDataSource _authStorage = AuthLocalDataSource(
    secureStorage: const FlutterSecureStorage(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PermissionManager.checkPermissions();
    _determineInitialUrl();
  }

  Future<void> _determineInitialUrl() async {
    try {
      final cookies = await CookieManager.instance().getCookies(
        url: WebUri("https://bullyapp.com.pe"),
      );
      final token = await _authStorage.getToken();

      bool hasSession = token != null && token.isNotEmpty;
      if (!hasSession && cookies.isNotEmpty) {
        hasSession = cookies.any((c) => c.name.startsWith('remember_web'));
      }

      if (mounted) {
        setState(() {
          if (hasSession) {
            _targetUrl = 'https://bullyapp.com.pe';
            isLoggedIn = true;
            _buttonText = "Resumen";
          } else {
            _targetUrl = 'https://bullyapp.com.pe/login';
            isLoggedIn = false;
            _buttonText = "Iniciar Sesión";
          }
          _isCheckingInitialSession = false;
        });
      }
    } catch (e) {
      debugPrint("Error al determinar URL inicial: $e");
      if (mounted) {
        setState(() {
          _targetUrl = 'https://bullyapp.com.pe/login';
          _isCheckingInitialSession = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _syncCookies();
    }
  }

  Future<void> _syncCookies() async {
    try {
      await CookieManager.instance().getCookies(url: WebUri("https://bullyapp.com.pe"));
    } catch (e) {
      debugPrint("Error syncing cookies on lifecycle change: $e");
    }
  }

  void _retryConnection() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    if (webViewController != null) {
      webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(_targetUrl)),
      );
    } else {
      _determineInitialUrl();
    }
  }

  Future<void> _fetchAndStoreBearerToken() async {
    if (webViewController == null) return;
    final existingToken = await _authStorage.getToken();
    if (existingToken != null && existingToken.isNotEmpty) {
      print("==================================================");
      print("🔑 TOKEN DE SESION WEB YA EXISTENTE EN MEMORIA:");
      print(existingToken);
      print("==================================================");
      return;
    }
    debugPrint("Inyectando script para obtener token de sesión web...");
    await webViewController?.evaluateJavascript(source: JSInjections.fetchSessionToken);
  }

  Future<void> _handleTokenReceived(Map<String, dynamic> tokenData) async {
    final String? token = tokenData['token'] as String?;
    if (token != null && token.isNotEmpty) {
      await _authStorage.saveToken(token);
      if (tokenData['user'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_user', jsonEncode(tokenData['user']));
      }
      isLoggedIn = true;
      print("==================================================");
      print("🔑 BEARER TOKEN DE SANCTUM OBTENIDO Y GUARDADO:");
      print(token);
      print("==================================================");
    }
  }

  Future<void> _clearToken() async {
    await _authStorage.clearToken();
    debugPrint("Token de sesión eliminado tras logout / login.");
  }

  void _onUrlUpdated(String url, InAppWebViewController? controller) {
    bool updatedShowAppBar = showGlobalAppBar;

    if (UrlHelper.isDashboard(url)) {
      updatedShowAppBar = true;
    }

    if (UrlHelper.isDashboard(url) || UrlHelper.isAnimalsManagement(url)) {
      isLoggedIn = true;
      _buttonText = "Resumen";
      _fetchAndStoreBearerToken();
    } else if (UrlHelper.isLoginOrLogout(url)) {
      isLoggedIn = false;
      _buttonText = "Iniciar Sesión";
      _clearToken();
    }

    if (updatedShowAppBar != showGlobalAppBar) {
      setState(() {
        showGlobalAppBar = updatedShowAppBar;
      });
    }

    final shouldShowFab = UrlHelper.esUrlDeAnimalEspecifico(url);
    if (shouldShowFab) {
      _checkChipStatusForAnimal();
    } else {
      if (_showFab) {
        setState(() {
          _showFab = false;
        });
      }
    }

    if (UrlHelper.isAnimalsManagement(url) && controller != null) {
      controller.evaluateJavascript(source: JSInjections.antiReactNfcStyle);
    }
  }

  Future<void> _checkChipStatusForAnimal() async {
    if (AnimalID <= 0) return;
    try {
      final animalDataSource = AnimalRemoteDataSource();
      final response = await animalDataSource.getAnimalDetails(AnimalID);

      bool show = true;
      if (response != null && response.animal != null) {
        if (response.animal!.chip != null) {
          show = false; // Si la respuesta contiene un chip, ya no se muestra el FAB
        }
      }

      if (mounted && _showFab != show) {
        setState(() {
          _showFab = show;
        });
      }
    } catch (e) {
      debugPrint("Error checking animal chip status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (webViewController != null && await webViewController!.canGoBack()) {
          await webViewController!.goBack();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        endDrawer: SideMenu(
          controller: webViewController,
          btnTextLogin: _buttonText,
        ),
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
                  if (!_isCheckingInitialSession)
                    BullyWebView(
                      initialUrl: _targetUrl,
                      onWebViewCreated: (controller) => webViewController = controller,
                      onUrlChanged: _onUrlUpdated,
                      onLoadingChanged: (loading) => setState(() => _isLoading = loading),
                      onErrorOccurred: (error) => setState(() => _hasError = error),
                      onTokenReceived: _handleTokenReceived,
                    ),
                  if (_isLoading || _isCheckingInitialSession) const LoadingView(),
                ],
              )
            : NoInternetView(onRetry: _retryConnection),
        bottomNavigationBar: MenuFooter(controller: webViewController),
        floatingActionButton: HomeFab(visible: _showFab),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
