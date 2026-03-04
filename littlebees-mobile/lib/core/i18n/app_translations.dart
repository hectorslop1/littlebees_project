import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_provider.dart';

class AppTranslations {
  final Locale locale;

  AppTranslations(this.locale);

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'home': 'Home',
      'activity': 'Activity',
      'chat': 'Chat',
      'calendar': 'Calendar',
      'me': 'Me',
      'messages': 'Messages',
      'profile': 'Profile',
      'photos': 'Photos',
      'activityLog': 'Activity Log',
      'todaySummary': 'Today\'s Summary',
      'checkedIn': 'Checked In',
      'checkedOut': 'Checked Out',
      'upcomingEvents': 'Upcoming Events',
      'children': 'Children',
      'settings': 'Settings',
      'familyInfo': 'Family Information',
      'authPickups': 'Authorized Pickups',
      'notifications': 'Notifications',
      'billing': 'Billing',
      'signOut': 'Sign Out',
      'agenda': 'Agenda',
      'typeMessage': 'Type a message...',
      'language': 'Language',
    },
    'es': {
      'home': 'Inicio',
      'activity': 'Actividad',
      'chat': 'Chat',
      'calendar': 'Calendario',
      'me': 'Perfil',
      'messages': 'Mensajes',
      'profile': 'Perfil',
      'photos': 'Fotos',
      'activityLog': 'Registro',
      'todaySummary': 'Resumen del Día',
      'checkedIn': 'Registrado',
      'checkedOut': 'Salida',
      'upcomingEvents': 'Próximos Eventos',
      'children': 'Hijos',
      'settings': 'Ajustes',
      'familyInfo': 'Información Familiar',
      'authPickups': 'Recogidas Autorizadas',
      'notifications': 'Notificaciones',
      'billing': 'Facturación',
      'signOut': 'Cerrar Sesión',
      'agenda': 'Agenda',
      'typeMessage': 'Escribe un mensaje...',
      'language': 'Idioma',
    }
  };

  String tr(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }
}

final translationsProvider = Provider<AppTranslations>((ref) {
  final locale = ref.watch(localeProvider);
  return AppTranslations(locale);
});
