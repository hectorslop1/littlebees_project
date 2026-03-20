class AppTranslations {
  // Títulos de pantallas
  static const String quickRegister = 'Registro Rápido';
  static const String daySchedule = 'Programación del Día';
  static const String activities = 'Actividades';
  
  // Tipos de actividades
  static const String checkIn = 'Entrada';
  static const String meal = 'Comida';
  static const String nap = 'Siesta';
  static const String activity = 'Actividad';
  static const String checkOut = 'Salida';
  
  // Etiquetas de formulario
  static const String selectActivity = 'Selecciona una actividad';
  static const String takePhoto = 'Tomar foto';
  static const String selectMood = 'Selecciona el estado de ánimo';
  static const String whatDidEat = '¿Qué comió?';
  static const String napDuration = 'Duración de la siesta (minutos)';
  static const String activityDescription = 'Descripción de la actividad';
  static const String additionalNotes = 'Notas adicionales (opcional)';
  
  // Estados de ánimo
  static const String moodVeryHappy = 'Muy feliz';
  static const String moodHappy = 'Feliz';
  static const String moodNeutral = 'Neutral';
  static const String moodSad = 'Triste';
  static const String moodVerySad = 'Muy triste';
  
  // Botones
  static const String register = 'Registrar';
  static const String cancel = 'Cancelar';
  static const String save = 'Guardar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String close = 'Cerrar';
  static const String retry = 'Reintentar';
  
  // Mensajes
  static const String registeredSuccessfully = 'Registrado exitosamente';
  static const String errorRegistering = 'Error al registrar';
  static const String loading = 'Cargando...';
  static const String noData = 'No hay datos disponibles';
  static const String selectChild = 'Selecciona un niño';
  static const String selectGroup = 'Selecciona un grupo';
  
  // Validaciones
  static const String fieldRequired = 'Este campo es requerido';
  static const String invalidValue = 'Valor inválido';
  static const String photoRequired = 'La foto es requerida';
  
  // Timeline
  static const String timeline = 'Línea de tiempo';
  static const String present = 'Presente';
  static const String absent = 'Ausente';
  static const String total = 'Total';
  
  // Días de la semana
  static const String monday = 'Lunes';
  static const String tuesday = 'Martes';
  static const String wednesday = 'Miércoles';
  static const String thursday = 'Jueves';
  static const String friday = 'Viernes';
  static const String saturday = 'Sábado';
  static const String sunday = 'Domingo';
  
  // Meses
  static const String january = 'Enero';
  static const String february = 'Febrero';
  static const String march = 'Marzo';
  static const String april = 'Abril';
  static const String may = 'Mayo';
  static const String june = 'Junio';
  static const String july = 'Julio';
  static const String august = 'Agosto';
  static const String september = 'Septiembre';
  static const String october = 'Octubre';
  static const String november = 'Noviembre';
  static const String december = 'Diciembre';
  
  // Helpers
  static String getActivityLabel(String type) {
    switch (type) {
      case 'check_in':
        return checkIn;
      case 'meal':
        return meal;
      case 'nap':
        return nap;
      case 'activity':
        return activity;
      case 'check_out':
        return checkOut;
      default:
        return type;
    }
  }
  
  static String getMoodLabel(String mood) {
    switch (mood) {
      case 'very_happy':
        return moodVeryHappy;
      case 'happy':
        return moodHappy;
      case 'neutral':
        return moodNeutral;
      case 'sad':
        return moodSad;
      case 'very_sad':
        return moodVerySad;
      default:
        return mood;
    }
  }
}
