import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Notificación en background: ${message.notification?.title}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ciemsi_channel',
    'CIEMSI Notificaciones',
    description: 'Notificaciones de citas médicas',
    importance: Importance.high,
  );

  static Future<void> inicializar() async {
    try {
      debugPrint('🔔 Iniciando NotificationService...');

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('🔔 Estado permisos: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('❌ Permisos de notificación denegados');
        return;
      }

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initSettings = InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(initSettings);
      debugPrint('✅ Notificaciones locales configuradas');

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _mostrarNotificacionLocal(message);
      });

      final token = await _messaging.getToken();
      debugPrint('🔑 Token FCM: $token');

      if (token != null) {
        await _guardarTokenEnServidor(token);
      } else {
        debugPrint('❌ Token FCM null - verificar cuenta Google en dispositivo');
      }

      _messaging.onTokenRefresh.listen((token) async {
        await _guardarTokenEnServidor(token);
      });

      debugPrint('✅ NotificationService inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error en NotificationService: $e');
    }
  }

  static Future<void> _guardarTokenEnServidor(String token) async {
    try {
      await ApiClientProvider.instance.dio.post(
        '/notificaciones/fcm-token',
        data: {'fcmToken': token},
      );
      debugPrint('✅ Token FCM guardado en servidor: $token');
    } catch (e) {
      debugPrint('❌ Error guardando token FCM: $e');
    }
  }

  static void _mostrarNotificacionLocal(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
