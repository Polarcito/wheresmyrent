import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static late String _lang;
  static late Map<String, String> _texts;

  /// Inicializa el servicio leyendo el idioma desde SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_locale') ?? 'en';

    _texts = _lang == 'es'
        ? {
            'notif_perm_title': 'Permiso necesario',
            'notif_perm_body': 'Para recibir recordatorios de arriendo, permite notificaciones en la configuración del sistema.',
            'notif_perm_openSettings': 'Abrir ajustes',
            'notif_perm_close': 'Cerrar',
            'notification_title': 'Arriendo pendiente',
            'notification_body':
                'La propiedad "{property}" tiene el arriendo vencido y aún no ha sido pagado.',
            'notification_channel_name': 'Recordatorio de arriendo',
            'notification_channel_description':
                'Notificaciones diarias para recordar pagos de arriendo pendientes',
          }
        : {
            'notif_perm_title': 'Permission required',
            'notif_perm_body': 'To receive rent reminders, please enable notifications in system settings.',
            'notif_perm_openSettings': 'Open settings',
            'notif_perm_close': 'Close',
            'notification_title': 'Pending rent',
            'notification_body':
                'The rent for "{property}" is overdue and has not been paid yet.',
            'notification_channel_name': 'Rent reminder',
            'notification_channel_description':
                'Daily notifications to remind about unpaid rent',
          };
  }

  /// Obtiene una traducción con parámetros opcionales
  static String t(String key, [Map<String, String>? params]) {
    var text = _texts[key] ?? key;
    params?.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  /// Idioma actual cargado
  static String get currentLang => _lang;
}
