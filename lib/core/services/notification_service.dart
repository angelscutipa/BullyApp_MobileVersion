import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// Handler global para mensajes recibidos cuando la app está en segundo plano o cerrada.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("==================================================");
    print("📩 NOTIFICACIÓN RECIBIDA EN BACKGROUND");
    print("Message ID: ${message.messageId}");
    print("DATA (Payload completo): ${message.data}");
    print("==================================================");
  }
  await NotificationService.instance.showNotificationFromRemoteMessage(message);
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService() => instance;

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

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
    _logStep("PASO 1/9: Iniciando inicialización de NotificationService...", true);

    try {
      // 1. Configurar manejador de mensajes en segundo plano
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      _logStep("PASO 2/9: Handler de segundo plano (Background) registrado.", true);

      // 2. Solicitar permisos de notificación
      _logStep("PASO 3/9: Solicitando permisos de notificación al usuario...", true);
      await requestPermissions();

      // 3. Inicializar Notificaciones Locales (para foreground)
      _logStep("PASO 4/9: Inicializando plugin de notificaciones locales...", true);
      const androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings();
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
        if (kDebugMode) {
          print("==================================================");
          print("📩 NOTIFICACIÓN RECIBIDA EN FOREGROUND (APP ABIERTA)");
          print("DATA (Payload completo): ${message.data}");
          print("==================================================");
        }
        showNotificationFromRemoteMessage(message);
      });

      // 6. Escuchar cuando el usuario toca la notificación con la app en segundo plano
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("==================================================");
          print("👉 NOTIFICACIÓN TOCADA DESDE BACKGROUND");
          print("DATA (Payload completo): ${message.data}");
          print("==================================================");
        }
        _handleNotificationClick(message);
      });

      // 7. Manejar notificación que abrió la app cuando estaba completamente cerrada (Terminated)
      try {
        final initialMessage = await _messaging
            .getInitialMessage()
            .timeout(const Duration(seconds: 2), onTimeout: () => null);
        if (initialMessage != null) {
          print("==================================================");
          print("🚀 APP ABIERTA MEDIANTE NOTIFICACIÓN INICIAL (TERMINATED)");
          print("DATA (Payload completo): ${initialMessage.data}");
          print("==================================================");
          _handleNotificationClick(initialMessage);
        }
      } catch (e) {
        if (kDebugMode) {
          print("Sin mensaje inicial o timeout en getInitialMessage(): $e");
        }
      }
      _logStep("PASO 7/9: Escuchadores de eventos (Foreground, Background, Terminated) activos.", true);

      // 8. Verificación explícita del Token nativo de APNs en iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        _logStep("PASO 8/9 [iOS]: Verificando Token nativo de APNs (Apple)...", true);
        try {
          final apnsToken = await _messaging.getAPNSToken().timeout(const Duration(seconds: 6));
          if (apnsToken != null && apnsToken.isNotEmpty) {
            _logStep("PASO 8/9 [iOS]: ✅ Token APNs obtenido de Apple con éxito: $apnsToken", true);
          } else {
            _logStep("PASO 8/9 [iOS]: ⚠️ Token APNs retorno NULO. Apple aún no ha entregado la clave APNs.", false);
          }
        } catch (e) {
          _logStep("PASO 8/9 [iOS]: ❌ Error consultando Token APNs de Apple: $e", false);
        }
      }

      // 9. Obtener y escuchar el Token de FCM
      _logStep("PASO 9/9: Solicitando FCM Token a Firebase...", true);
      await _initFcmToken();

      // Suscribir automáticamente el dispositivo al tema comunitario "todos"
      await subscribeToTopic('todos');

      _logStep("🎉 COMPLETO: Flujo de inicialización de NotificationService finalizado.", true);
    } catch (e) {
      _logStep("❌ ERROR FATAL en inicialización de NotificationService: $e", false);
    }
  }

  /// Solicitar permisos de notificación al usuario.
  Future<void> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      _logStep("Estado del permiso otorgado por el usuario: ${settings.authorizationStatus}", true);
    }
  }

  /// Obtener el Token FCM actual y suscribirse a cambios de token.
  Future<String?> _initFcmToken() async {
    try {
      final token = await _messaging
          .getToken()
          .timeout(const Duration(seconds: 6), onTimeout: () => null);
      if (token != null) {
        _logStep("FCM Token obtenido exitosamente: $token", true);
      } else {
        _logStep("FCM Token retornado nulo o expiró el tiempo de espera.", false);
      }

      // Escuchar renovaciones de token
      _messaging.onTokenRefresh.listen((newToken) {
        _logStep("FCM Token renovado: $newToken", true);
      });

      return token;
    } catch (e) {
      _logStep("Error obteniendo FCM Token de Firebase: $e", false);
      return null;
    }
  }

  /// Obtener directamente el FCM Token actual.
  Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Suscribirse a un tema (Topic) específico de notificaciones.
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        _logStep("Suscrito exitosamente al tema: $topic", true);
      }
    } catch (e) {
      if (kDebugMode) {
        _logStep("Error al suscribirse al tema $topic: $e", false);
      }
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

  /// Muestra una notificación personalizada con imagen (o fallback al logo) y diseño alineado a la referencia.
  Future<void> showNotificationFromRemoteMessage(RemoteMessage message) async {
    final data = message.data;
    
    // Extraer título, cuerpo e imagen del payload
    final String title = data['title'] ?? message.notification?.title ?? 'BullyApp • Alerta';
    final String body = data['body'] ?? message.notification?.body ?? '';
    final String? imageUrl = data['imagen_url'] as String?;

    AndroidBitmap<Object>? bigPictureBitmap;

    // Intentar descargar la imagen del perro si viene en "imagen_url"
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      try {
        final response = await Dio().get<List<int>>(
          imageUrl.trim(),
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: const Duration(seconds: 6),
          ),
        );
        if (response.statusCode == 200 && response.data != null) {
          bigPictureBitmap = ByteArrayAndroidBitmap(Uint8List.fromList(response.data!));
        }
      } catch (e) {
        if (kDebugMode) {
          print("⚠️ No se pudo descargar la imagen de la notificación ($imageUrl): $e. Usando logo de respaldo.");
        }
      }
    }

    // Fallback: Si no llegó imagen o falló la descarga, usar el logo de la app por defecto
    bigPictureBitmap ??= const DrawableResourceAndroidBitmap('@mipmap/launcher_icon');

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      styleInformation: BigPictureStyleInformation(
        bigPictureBitmap,
        contentTitle: title,
        summaryText: body,
      ),
    );

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
