enum AppLanguage {
  es,
  en,
}

class AppLocalizations {
  const AppLocalizations(this.language);

  final AppLanguage language;

  bool get isSpanish => language == AppLanguage.es;

  String get appName => 'Mundialito';
  String get greeting => isSpanish ? 'Buenos dias' : 'Good morning';
  String get fanName => isSpanish ? 'Hincha mundialista' : 'World Cup fan';
  String get headline =>
      isSpanish ? 'Vive cada jugada' : 'Track every minute';
  String get subtitle => isSpanish
      ? 'Resultados, calendario y tabla del Mundial en un solo lugar.'
      : 'Scores, schedule and standings for the World Cup in one place.';
  String get live => isSpanish ? 'En vivo' : 'Live';
  String get schedule => isSpanish ? 'Calendario' : 'Schedule';
  String get groups => isSpanish ? 'Grupos' : 'Groups';
  String get history => isSpanish ? 'Historico' : 'History';
  String get featuredMatch => isSpanish ? 'Partido destacado' : 'Featured match';
  String get topEvents => isSpanish ? 'Eventos principales' : 'Top events';
  String get viewAll => isSpanish ? 'Ver todo' : 'View all';
  String get noMatches => isSpanish
      ? 'No hay partidos para este filtro.'
      : 'No matches for this filter.';
  String get standings => isSpanish ? 'Tabla de posiciones' : 'Standings';
  String get teams => isSpanish ? 'Equipos' : 'Teams';
  String get minuteByMinute =>
      isSpanish ? 'Minuto a minuto' : 'Minute by minute';
  String get matchDetails => isSpanish ? 'Detalle del partido' : 'Match details';
  String get statusConfigured =>
      isSpanish ? 'API conectada' : 'API connected';
  String get statusError => isSpanish ? 'Error de datos' : 'Data error';
  String get statusNeedsConfig => isSpanish
      ? 'Configura Flupibase para cargar datos reales'
      : 'Configure Flupibase to load real data';
  String get refresh => isSpanish ? 'Actualizar' : 'Refresh';
  String get retry => isSpanish ? 'Reintentar' : 'Retry';
  String get upcoming => isSpanish ? 'Proximo' : 'Upcoming';
  String get finished => isSpanish ? 'Finalizado' : 'Finished';
  String get halftime => isSpanish ? 'Descanso' : 'Half-time';
  String get allMatches => isSpanish ? 'Todos' : 'All';
  String get today => isSpanish ? 'Hoy' : 'Today';
  String get venue => isSpanish ? 'Estadio' : 'Venue';
  String get season => isSpanish ? 'Temporada' : 'Season';
  String get realDataHint => isSpanish
      ? 'Se usaran datos reales via Flupibase Functions.'
      : 'Uses real data through Flupibase Functions.';
  String get noEventsYet => isSpanish
      ? 'Aun no hay eventos minuto a minuto.'
      : 'No minute-by-minute events yet.';
  String get configuring => isSpanish ? 'Preparando Mundialito' : 'Preparing Mundialito';
  String get languageAction => isSpanish ? 'English' : 'Espanol';
  String get loadingSeason =>
      isSpanish ? 'Cargando temporada...' : 'Loading season...';

  String playedShort(int value) => isSpanish ? 'PJ $value' : 'P $value';
  String pointsShort(int value) => isSpanish ? '$value pts' : '$value pts';
}
