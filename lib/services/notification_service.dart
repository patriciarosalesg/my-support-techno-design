import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final permissions = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();

    debugPrint(
      'PERMISOS NOTIFICACION: ${permissions?.isEnabled}',
    );
  }

  static Future<void> showRegistrationNotification() async {
    debugPrint(
      'NOTIFICACION: showRegistrationNotification EJECUTADO',
    );

    const DarwinNotificationDetails details =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(
      iOS: details,
    );

    await _notifications.show(
      0,
      'Registro exitoso',
      'Usuario registrado correctamente.',
      notificationDetails,
    );
  }

  // Muestra una notificación cuando cambia el estado
  // de una orden de servicio.
  static Future<void> showStatusNotification(
    String estado,
    String equipo,
  ) async {
    String titulo;
    String mensaje;

    switch (estado) {
      case 'En reparación':
        titulo = 'Actualización de tu servicio';
        mensaje =
            'Tu $equipo pasó a la etapa de reparación.';
        break;

      case 'Lista para entrega':
        titulo = '¡Tu equipo está listo!';
        mensaje =
            'Tu $equipo ya está listo para recogerlo.';
        break;

      case 'En diagnóstico':
        titulo = 'Actualización de tu servicio';
        mensaje =
            'Tu $equipo está en etapa de diagnóstico.';
        break;

      default:
        titulo = 'Actualización de tu servicio';
        mensaje =
            'El estado de tu $equipo cambió a $estado.';
    }

    const DarwinNotificationDetails details =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(
      iOS: details,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      titulo,
      mensaje,
      notificationDetails,
    );
  }
}