import '../domain/mundial_models.dart';

class FootballApiMapper {
  static List<MundialMatch> matchesFromFixtures(
    Map<String, dynamic> json, {
    required int season,
  }) {
    final response = json['response'];
    if (response is! List) {
      return const <MundialMatch>[];
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map((item) => _matchFromJson(item, fallbackSeason: season))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static MundialMatch? firstMatchFromFixture(
    Map<String, dynamic> json, {
    required int season,
  }) {
    final response = json['response'];
    if (response is! List || response.isEmpty) {
      return null;
    }

    Map<String, dynamic>? first;
    for (final item in response.whereType<Map<String, dynamic>>()) {
      first = item;
      break;
    }

    if (first == null) {
      return null;
    }

    return _matchFromJson(first, fallbackSeason: season);
  }

  static List<StandingRow> standingsFromJson(Map<String, dynamic> json) {
    final rows = <StandingRow>[];
    final response = json['response'];
    if (response is! List) {
      return rows;
    }

    for (final leagueItem in response.whereType<Map<String, dynamic>>()) {
      final league = _map(leagueItem['league']);
      final standings = league['standings'];
      if (standings is! List) {
        continue;
      }

      for (final groupRows in standings) {
        if (groupRows is! List) {
          continue;
        }

        for (final row in groupRows.whereType<Map<String, dynamic>>()) {
          final team = _teamFromJson(_map(row['team']));
          final all = _map(row['all']);
          final goals = _map(all['goals']);
          rows.add(
            StandingRow(
              group: _string(row['group'], fallback: 'Group'),
              rank: _int(row['rank']),
              team: team,
              played: _int(all['played']),
              win: _int(all['win']),
              draw: _int(all['draw']),
              lose: _int(all['lose']),
              goalsFor: _int(goals['for']),
              goalsAgainst: _int(goals['against']),
              goalsDiff: _int(row['goalsDiff']),
              points: _int(row['points']),
              form: _nullableString(row['form']),
            ),
          );
        }
      }
    }

    rows.sort((a, b) {
      final groupCompare = a.group.compareTo(b.group);
      if (groupCompare != 0) {
        return groupCompare;
      }
      return a.rank.compareTo(b.rank);
    });
    return rows;
  }

  static List<TeamRef> teamsFromJson(Map<String, dynamic> json) {
    final response = json['response'];
    if (response is! List) {
      return const <TeamRef>[];
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map((item) => _teamFromJson(_map(item['team'])))
        .where((team) => team.name.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static MundialMatch _matchFromJson(
    Map<String, dynamic> item, {
    required int fallbackSeason,
  }) {
    final fixture = _map(item['fixture']);
    final league = _map(item['league']);
    final teams = _map(item['teams']);
    final goals = _map(item['goals']);
    final venue = _map(fixture['venue']);
    final status = _map(fixture['status']);
    final eventsJson = item['events'];

    final match = MundialMatch(
      id: _int(fixture['id']),
      season: _int(league['season'], fallback: fallbackSeason),
      round: _string(league['round'], fallback: 'World Cup'),
      date: _date(fixture['date']),
      home: _teamFromJson(_map(teams['home'])),
      away: _teamFromJson(_map(teams['away'])),
      status: MatchStatus(
        long: _string(status['long'], fallback: 'Scheduled'),
        short: _string(status['short'], fallback: 'NS'),
        elapsed: _int(status['elapsed']),
        extra: _nullableInt(status['extra']),
      ),
      homeGoals: _nullableInt(goals['home']),
      awayGoals: _nullableInt(goals['away']),
      venueName: _nullableString(venue['name']),
      venueCity: _nullableString(venue['city']),
      events: const <MatchEvent>[],
    );

    if (eventsJson is! List) {
      return match;
    }

    return match.copyWithEvents(
      eventsJson
          .whereType<Map<String, dynamic>>()
          .map(_eventFromJson)
          .toList()
        ..sort((a, b) => b.minute.compareTo(a.minute)),
    );
  }

  static MatchEvent _eventFromJson(Map<String, dynamic> item) {
    final time = _map(item['time']);
    final team = _teamFromJson(_map(item['team']));
    final player = _map(item['player']);
    final assist = _map(item['assist']);

    return MatchEvent(
      minute: _int(time['elapsed']),
      extraMinute: _nullableInt(time['extra']),
      team: team,
      player: _nullableString(player['name']),
      assist: _nullableString(assist['name']),
      type: _string(item['type'], fallback: 'Event'),
      detail: _string(item['detail'], fallback: 'Match event'),
      comments: _nullableString(item['comments']),
    );
  }

  static TeamRef _teamFromJson(Map<String, dynamic> item) {
    return TeamRef(
      id: _int(item['id']),
      name: _string(item['name'], fallback: 'TBD'),
      code: _nullableString(item['code']),
      logoUrl: _nullableString(item['logo']),
      country: _nullableString(item['country']),
    );
  }

  static Map<String, dynamic> _map(Object? value) {
    return value is Map<String, dynamic> ? value : const <String, dynamic>{};
  }

  static DateTime _date(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  static String _string(Object? value, {required String fallback}) {
    if (value == null) {
      return fallback;
    }
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static String? _nullableString(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int _int(Object? value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static int? _nullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
