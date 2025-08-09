import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:hive/hive.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:wheresmyrent/model/monthly_rent_block.dart';
import 'package:wheresmyrent/model/generic/config.dart';
import 'package:wheresmyrent/model/services/translation_service.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// Inicializa notificaciones y configura zona horaria
  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);

    tz_data.initializeTimeZones();
  }

  static Future<void> requestNotificationPermissionIfNeeded() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      final sdk = info.version.sdkInt;

      if (sdk >= 33) {
        final granted = await FlutterLocalNotificationsPlugin()
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();

        if (granted != true) {
          debugPrint('❌ El usuario NO concedió el permiso de notificaciones.');
          return;
        } else {
          debugPrint('✅ Permiso de notificaciones concedido.');
        }
      } else {
        debugPrint('ℹ️ Android < 13, no necesita pedir permiso.');
      }
    }
  }

  /// Programa notificaciones diarias para propiedades con arriendo vencido y no pagado
  static Future<void> scheduleDailyOverdueRentNotifications() async {
    await _notifications.cancelAll(); // Limpia notificaciones anteriores

    final box = Hive.box<Property>(Config.boxName);
    final now = DateTime.now();

    for (final property in box.values) {
      final block = property.monthlyBlocks.firstWhere(
        (b) => b.year == now.year && b.month == now.month,
        orElse: () => MonthlyRentBlock(year: now.year, month: now.month, effectiveRent: property.monthlyRent),
      );

      final dueDate = DateTime(now.year, now.month, property.dueDay);
      final totalPaid = block.payments.fold<double>(0.0, (sum, p) => sum + p.amount);
      final expected = block.effectiveRent;

      final isOverdue = now.isAfter(dueDate);
      final isUnpaid = totalPaid < expected;

      if (isOverdue && isUnpaid) {
        final shortName = property.name.length > 30
            ? '${property.name.substring(0, 27)}...'
            : property.name;

        await _notifications.zonedSchedule(
          property.hashCode,
          TranslationService.t('notification_title'),
          TranslationService.t('notification_body', {'property': shortName}),
          _nextInstanceAtHour(12),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'rent_reminder_channel',
              TranslationService.t('notification_channel_name'),
              channelDescription: TranslationService.t('notification_channel_description'),
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  }

  /// Hora en la que se activará diariamente la notificación (ej: 12:00)
  static tz.TZDateTime _nextInstanceAtHour(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);

    return scheduled.isAfter(now)
        ? scheduled
        : scheduled.add(const Duration(days: 1));
  }

  static tz.TZDateTime _nextInstanceInSeconds(int secondsFromNow) {
    final now = tz.TZDateTime.now(tz.local);
    return now.add(Duration(seconds: secondsFromNow));
  }

  /*
  static Future<void> testImmediateNotification() async {
    await _notifications.zonedSchedule(
      999,
      TranslationService.t('notification_title'),
      TranslationService.t('notification_body', {'property': 'Casa de prueba'}),
      _nextInstanceInSeconds(10),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          TranslationService.t('notification_channel_name'),
          channelDescription: TranslationService.t('notification_channel_description'),
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  */

  static Future<void> testImmediateNotification() async {
    final now = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    await _notifications.zonedSchedule(
      987, // ID cualquiera
      '🔔 Prueba real',
      '¿Ves esta notificación con la app cerrada?',
      now,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'real_test_channel',
          'Canal real',
          channelDescription: 'Canal para pruebas reales',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint("🧨 Notificación agendada para: $now");
    debugPrint("🧨 aa: ${tz.local}");
  }

}
