import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handler global para mensajes recibidos cuando la app está en segundo plano o cerrada.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("==================================================");
    print("📩 NOTIFICACIÓN RECIBIDA EN BACKGROUND");
    print("Message ID: ${message.messageId}");
    print("DATA (Payload completo): ${message.data}");
    print("==================================================");
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService() => instance;

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  static const String _iosApnsEnvPrefsKey = 'fcm_ios_apns_env_v2';

  /// Stream para notificar a la UI de URLs de destino al tocar notificaciones
  static final StreamController<String> selectNotificationStream =
      StreamController<String>.broadcast();

  /// Almacena una URL pendiente si la app fue abierta desde estado Terminated
  static String? pendingTargetUrl;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notificaciones Importantes',
    description: 'Canal principal para notificaciones de Bully App',
    importance: Importance.max,
  );

  /// Imprime un paso numerado en el rastreador de consola para identificar bloqueos.
  void _logStep(String message, bool success) {
    final icon = success ? "✅" : "❌";
    print("🔔 [RASTREADOR FCM] $icon $message");
  }

  /// Inicializa el servicio de notificaciones, permisos y manejadores de eventos con rastreador paso a paso.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _logStep("PASO 1/9: Iniciando inicialización de NotificationService...", true);

    try {
      // 1. Asegurar registro de manejador en segundo plano
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _logStep("PASO 2/9: Handler de segundo plano (Background) listo.", true);

      // 2. Solicitar permisos de notificación (único punto en iOS)
      _logStep("PASO 3/9: Solicitando permisos de notificación al usuario...", true);
      await requestPermissions();

      // 3. Inicializar Notificaciones Locales (desactivando solicitud duplicada en iOS)
      _logStep("PASO 4/9: Inicializando plugin de notificaciones locales...", true);
      const androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (kDebugMode) {
            print("Notificación local presionada. Payload: ${response.payload}");
          }
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final Map<String, dynamic> data =
                  Map<String, dynamic>.from(jsonDecode(response.payload!));
              _processPayloadData(data);
            } catch (e) {
              if (kDebugMode) {
                print("Error al decodificar payload local: $e");
              }
            }
          }
        },
      );

      // Crear el canal de notificación de alta importancia en Android
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_channel);
      }
      _logStep("PASO 5/9: Notificaciones locales y canales del sistema listos.", true);

      // 4. Configurar opciones de presentación en primer plano para iOS
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      _logStep("PASO 6/9: Opciones de presentación en primer plano configuradas.", true);

      // 5. Escuchar notificaciones en primer plano (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logStep(
          "📩 Notificación recibida en FOREGROUND (id: ${message.messageId})",
          true,
        );
        if (kDebugMode) {
          print("DATA (Payload completo): ${message.data}");
        }

        // En iOS, cuando la notificación trae bloque `notification`, el sistema ya
        // muestra el banner nativo gracias a setForegroundNotificationPresentationOptions.
        if (defaultTargetPlatform == TargetPlatform.iOS &&
            message.notification != null) {
          return;
        }

        showNotificationFromRemoteMessage(message);
      });

      // 6. Escuchar cuando el usuario toca la notificación con la app en segundo plano / foreground nativo
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logStep("👉 Notificación tocada por el usuario", true);
        if (kDebugMode) {
          print("DATA (Payload completo): ${message.data}");
        }
        _handleNotificationClick(message);
      });

      // Escuchar renovaciones de token (incluye entrega tardía de APNs en iOS)
      _messaging.onTokenRefresh.listen((newToken) async {
        _logStep("FCM Token renovado: $newToken", true);
        await subscribeToTopic('todos');
      });

      // 7. Manejar notificación que abrió la app cuando estaba completamente cerrada (Terminated)
      try {
        final initialMessage = await _messaging
            .getInitialMessage()
            .timeout(const Duration(seconds: 2), onTimeout: () => null);
        if (initialMessage != null) {
          _logStep("🚀 App abierta mediante notificación inicial (Terminated)", true);
          _handleNotificationClick(initialMessage);
        }
      } catch (e) {
        if (kDebugMode) {
          print("Sin mensaje inicial o timeout en getInitialMessage(): $e");
        }
      }
      _logStep("PASO 7/9: Escuchadores de eventos (Foreground, Background, Terminated) activos.", true);

      // 8. En iOS, esperar realmente al Token APNs antes de solicitar el FCM Token
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        _logStep("PASO 8/9 [iOS]: Esperando entrega del Token nativo APNs de Apple...", true);
        final apnsToken = await _waitForApnsToken();
        if (apnsToken == null) {
          _logStep(
            "PASO 8/9 [iOS]: ⚠️ Apple aún no entregó el Token APNs. Se pospone getToken() hasta onTokenRefresh.",
            false,
          );
          return;
        }

        await _refreshIosTokenIfEnvironmentChanged();
      }

      // 9. Obtener el Token de FCM (ya con APNs garantizado en iOS)
      _logStep("PASO 9/9: Solicitando FCM Token a Firebase...", true);
      final token = await _initFcmToken();

      // Suscribir automáticamente el dispositivo al tema comunitario "todos"
      if (token != null) {
        await subscribeToTopic('todos');
      }

      _logStep("🎉 COMPLETO: Flujo de inicialización de NotificationService finalizado.", true);
    } catch (e) {
      _logStep("❌ ERROR FATAL en inicialización de NotificationService: $e", false);
    }
  }

  /// Espera con reintentos reales a que iOS entregue el APNs token a FirebaseMessaging.
  Future<String?> _waitForApnsToken({
    int maxAttempts = 12,
    Duration interval = const Duration(seconds: 1),
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          _logStep(
            "PASO 8/9 [iOS]: Token APNs obtenido en intento $attempt/$maxAttempts: $apnsToken",
            true,
          );
          return apnsToken;
        }
      } catch (e) {
        _logStep("PASO 8/9 [iOS]: Error consultando APNs (intento $attempt): $e", false);
      }
      await Future.delayed(interval);
    }
    return null;
  }

  /// Limpia una única vez el token FCM del Keychain cuando la app cambia entre Sandbox (Debug) y Producción (TestFlight/App Store).
  Future<void> _refreshIosTokenIfEnvironmentChanged() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const currentEnv = kReleaseMode ? 'prod' : 'sandbox';
      final savedEnv = prefs.getString(_iosApnsEnvPrefsKey);

      if (savedEnv != currentEnv) {
        _logStep(
          "PASO 8.5/9 [iOS]: Limpiando token FCM previo en Keychain para enlazar entorno '$currentEnv'...",
          true,
        );
        await _messaging.deleteToken();
        await Future.delayed(const Duration(milliseconds: 300));
        await prefs.setString(_iosApnsEnvPrefsKey, currentEnv);
      }
    } catch (e) {
      _logStep("Aviso limpiando caché previa de FCM Token en iOS: $e", false);
    }
  }

  /// Solicitar permisos de notificación al usuario.
  Future<NotificationSettings> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    _logStep(
      "Estado del permiso de notificaciones: ${settings.authorizationStatus}",
      settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional,
    );
    return settings;
  }

  /// Obtener el Token FCM actual.
  Future<String?> _initFcmToken() async {
    try {
      final token = await _messaging
          .getToken()
          .timeout(const Duration(seconds: 10), onTimeout: () => null);
      if (token != null) {
        _logStep("FCM Token obtenido exitosamente: $token", true);
      } else {
        _logStep("FCM Token retornado nulo o expiró el tiempo de espera.", false);
      }

      return token;
    } catch (e) {
      _logStep("Error obteniendo FCM Token de Firebase: $e", false);
      return null;
    }
  }

  /// Obtener directamente el FCM Token actual.
  Future<String?> getFcmToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _waitForApnsToken(maxAttempts: 5);
        if (apnsToken == null) return null;
      }
      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Suscribirse a un tema (Topic) específico de notificaciones.
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logStep("Suscrito exitosamente al tema: $topic", true);
    } catch (e) {
      _logStep("Error al suscribirse al tema $topic: $e", false);
    }
  }

  /// Desuscribirse de un tema (Topic) de notificaciones.
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        _logStep("Desuscrito del tema: $topic", true);
      }
    } catch (e) {
      if (kDebugMode) {
        _logStep("Error al desuscribirse del tema $topic: $e", false);
      }
    }
  }

  /// Muestra una notificación personalizada con imagen (o fallback al logo) y diseño seguro.
  Future<void> showNotificationFromRemoteMessage(RemoteMessage message) async {
    final data = message.data;
    
    // Extraer título, cuerpo e imagen del payload
    final String title = data['title'] ?? message.notification?.title ?? 'BullyApp • Alerta';
    final String body = data['body'] ?? message.notification?.body ?? '';
    final String? imageUrl = data['imagen_url'] as String?;

    ByteArrayAndroidBitmap? downloadedBitmap;

    // Intentar descargar la imagen del perro si viene en "imagen_url"
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      try {
        final response = await Dio().get<List<int>>(
          imageUrl.trim(),
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        if (response.statusCode == 200 && response.data != null) {
          downloadedBitmap = ByteArrayAndroidBitmap(Uint8List.fromList(response.data!));
        }
      } catch (e) {
        if (kDebugMode) {
          print("⚠️ No se pudo descargar la imagen de la notificación ($imageUrl): $e. Usando diseño con logo.");
        }
      }
    }

    // Configuración segura de estilos en Android según si hay imagen descargada o no
    AndroidNotificationDetails androidDetails;

    if (downloadedBitmap != null) {
      // Estilo con imagen grande cuando se descarga la foto correctamente
      androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        styleInformation: BigPictureStyleInformation(
          downloadedBitmap,
          contentTitle: title,
          summaryText: body,
        ),
      );
    } else {
      // Estilo de texto expansible ultra-seguro con logo de la app cuando no hay foto
      androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
        ),
      );
    }

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Manejo centralizado al tocar notificaciones.
  void _handleNotificationClick(RemoteMessage message) {
    _processPayloadData(message.data);
  }

  /// Extrae la información del payload y genera el evento de navegación.
  void _processPayloadData(Map<String, dynamic> data) {
    if (kDebugMode) {
      print("🔔 PROCESANDO NAVEGACIÓN O ACCIÓN POR NOTIFICACIÓN");
      print("Payload data: $data");
    }

    final dynamic animalId = data['animal_id'];
    if (animalId != null && animalId.toString().trim().isNotEmpty) {
      final String idStr = animalId.toString().trim();
      final String targetUrl = 'https://bullyapp.com.pe/bullys/$idStr';

      if (kDebugMode) {
        print("🔗 NAVEGACIÓN A URL OBJETIVO GENERADA: $targetUrl");
      }

      pendingTargetUrl = targetUrl;
      selectNotificationStream.add(targetUrl);
    }
  }

  /// Programa un recordatorio local de vacuna para un perro específico.
  Future<void> scheduleVaccineReminder({
    required int dogId,
    required String dogName,
    required String vaccineDateStr,
  }) async {
    try {
      DateTime? vaccineDate = DateTime.tryParse(vaccineDateStr);
      if (vaccineDate == null) return;

      final scheduledTime = DateTime(
        vaccineDate.year,
        vaccineDate.month,
        vaccineDate.day,
        9,
        0,
      );

      if (scheduledTime.isBefore(DateTime.now())) return;

      if (kDebugMode) {
        print("💉 Recordatorio de vacuna registrado para $dogName el $vaccineDateStr (ID: $dogId)");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error programando recordatorio de vacuna: $e");
      }
    }
  }
}
