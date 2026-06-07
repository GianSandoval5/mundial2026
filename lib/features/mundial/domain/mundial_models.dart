enum MundialDataMode {
  remote,
  notConfigured,
  error,
}

class MundialSnapshot {
  const MundialSnapshot({
    required this.season,
    required this.matches,
    required this.standings,
    required this.teams,
    required this.mode,
    this.message,
  });

  final int season;
  final List<MundialMatch> matches;
  final List<StandingRow> standings;
  final List<TeamRef> teams;
  final MundialDataMode mode;
  final String? message;

  bool get isRemote => mode == MundialDataMode.remote;

  MundialMatch? get featuredMatch {
    final live = matches.where((match) => match.isLive).toList()
      ..sort((a, b) => b.status.elapsed.compareTo(a.status.elapsed));
    if (live.isNotEmpty) {
      return live.first;
    }

    final now = DateTime.now();
    final upcoming = matches
        .where((match) => match.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (upcoming.isNotEmpty) {
      return upcoming.first;
    }

    final finished = List<MundialMatch>.from(matches)
      ..sort((a, b) => b.date.compareTo(a.date));
    return finished.isEmpty ? null : finished.first;
  }

  List<DateTime> get matchDays {
    final days = <String, DateTime>{};
    for (final match in matches) {
      final local = match.date.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      days['${day.year}-${day.month}-${day.day}'] = day;
    }

    final values = days.values.toList()..sort();
    return values;
  }
}

class TeamRef {
  const TeamRef({
    required this.id,
    required this.name,
    this.code,
    this.logoUrl,
    this.country,
  });

  final int id;
  final String name;
  final String? code;
  final String? logoUrl;
  final String? country;

  String get shortName {
    if (code != null && code!.trim().isNotEmpty) {
      return code!.toUpperCase();
    }

    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.length == 1) {
      return parts.first.length <= 3
          ? parts.first.toUpperCase()
          : parts.first.substring(0, 3).toUpperCase();
    }

    return parts.take(3).map((part) => part[0]).join().toUpperCase();
  }
}

class MatchStatus {
  const MatchStatus({
    required this.long,
    required this.short,
    this.elapsed = 0,
    this.extra,
  });

  final String long;
  final String short;
  final int elapsed;
  final int? extra;

  bool get isLive {
    const liveCodes = <String>{'1H', 'HT', '2H', 'ET', 'P', 'BT', 'LIVE'};
    return liveCodes.contains(short.toUpperCase());
  }

  bool get isFinished {
    const finishedCodes = <String>{'FT', 'AET', 'PEN'};
    return finishedCodes.contains(short.toUpperCase());
  }

  bool get isNotStarted => short.toUpperCase() == 'NS';
}

class MundialMatch {
  const MundialMatch({
    required this.id,
    required this.season,
    required this.round,
    required this.date,
    required this.home,
    required this.away,
    required this.status,
    required this.events,
    this.homeGoals,
    this.awayGoals,
    this.venueName,
    this.venueCity,
  });

  final int id;
  final int season;
  final String round;
  final DateTime date;
  final TeamRef home;
  final TeamRef away;
  final MatchStatus status;
  final int? homeGoals;
  final int? awayGoals;
  final String? venueName;
  final String? venueCity;
  final List<MatchEvent> events;

  bool get isLive => status.isLive;
  bool get isFinished => status.isFinished;
  bool get isUpcoming => status.isNotStarted;

  String get scoreText {
    final homeValue = homeGoals?.toString() ?? '-';
    final awayValue = awayGoals?.toString() ?? '-';
    return '$homeValue : $awayValue';
  }

  String get venueText {
    final parts = <String>[
      if (venueName != null && venueName!.trim().isNotEmpty) venueName!,
      if (venueCity != null && venueCity!.trim().isNotEmpty) venueCity!,
    ];
    return parts.join(', ');
  }

  MundialMatch copyWithEvents(List<MatchEvent> value) {
    return MundialMatch(
      id: id,
      season: season,
      round: round,
      date: date,
      home: home,
      away: away,
      status: status,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      venueName: venueName,
      venueCity: venueCity,
      events: value,
    );
  }
}

class MatchEvent {
  const MatchEvent({
    required this.minute,
    required this.team,
    required this.type,
    required this.detail,
    this.extraMinute,
    this.player,
    this.assist,
    this.comments,
  });

  final int minute;
  final int? extraMinute;
  final TeamRef team;
  final String type;
  final String detail;
  final String? player;
  final String? assist;
  final String? comments;

  String get minuteLabel {
    if (extraMinute == null || extraMinute == 0) {
      return "$minute'";
    }
    return "$minute+$extraMinute'";
  }
}

class StandingRow {
  const StandingRow({
    required this.group,
    required this.rank,
    required this.team,
    required this.played,
    required this.win,
    required this.draw,
    required this.lose,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalsDiff,
    required this.points,
    this.form,
  });

  final String group;
  final int rank;
  final TeamRef team;
  final int played;
  final int win;
  final int draw;
  final int lose;
  final int goalsFor;
  final int goalsAgainst;
  final int goalsDiff;
  final int points;
  final String? form;
}
