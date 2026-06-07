import 'football_api_mapper.dart';
import 'football_api_service.dart';
import '../domain/mundial_models.dart';

class FootballRepository {
  const FootballRepository(this._api);

  final FootballApiService _api;

  bool get hasRemoteApi => _api.isConfigured;

  Future<MundialSnapshot> loadSeason(int season) async {
    if (!_api.isConfigured) {
      return MundialSnapshot(
        season: season,
        matches: const <MundialMatch>[],
        standings: const <StandingRow>[],
        teams: const <TeamRef>[],
        mode: MundialDataMode.notConfigured,
        message: 'Flupibase runtime config is not complete.',
      );
    }

    try {
      final fixturesJson = await _api.fetchFixtures(season: season);
      final fixturesError = _apiErrorMessage(fixturesJson);
      if (fixturesError != null) {
        return _errorSnapshot(season, fixturesError);
      }

      final results = await Future.wait(<Future<Map<String, dynamic>>>[
        _api.fetchStandings(season: season),
        _api.fetchTeams(season: season),
      ]);

      final matches = FootballApiMapper.matchesFromFixtures(
        fixturesJson,
        season: season,
      );
      final standingsError = _apiErrorMessage(results[0]);
      final teamsError = _apiErrorMessage(results[1]);
      final standings = standingsError == null
          ? FootballApiMapper.standingsFromJson(results[0])
          : const <StandingRow>[];
      final teams = teamsError == null
          ? FootballApiMapper.teamsFromJson(results[1])
          : const <TeamRef>[];

      return MundialSnapshot(
        season: season,
        matches: matches,
        standings: standings,
        teams: teams,
        mode: MundialDataMode.remote,
      );
    } catch (error) {
      return MundialSnapshot(
        season: season,
        matches: const <MundialMatch>[],
        standings: const <StandingRow>[],
        teams: const <TeamRef>[],
        mode: MundialDataMode.error,
        message: error.toString(),
      );
    }
  }

  Future<MundialMatch?> loadMatchDetail({
    required int fixtureId,
    required int season,
  }) async {
    if (!_api.isConfigured) {
      return null;
    }

    try {
      final json = await _api.fetchFixtureDetail(
        fixtureId: fixtureId,
        season: season,
      );
      return FootballApiMapper.firstMatchFromFixture(json, season: season);
    } catch (_) {
      return null;
    }
  }

  MundialSnapshot _errorSnapshot(int season, String message) {
    return MundialSnapshot(
      season: season,
      matches: const <MundialMatch>[],
      standings: const <StandingRow>[],
      teams: const <TeamRef>[],
      mode: MundialDataMode.error,
      message: message,
    );
  }

  String? _apiErrorMessage(Map<String, dynamic> json) {
    final errors = json['errors'];
    if (errors == null) {
      return null;
    }

    if (errors is List && errors.isEmpty) {
      return null;
    }

    if (errors is Map && errors.isEmpty) {
      return null;
    }

    if (errors is Map) {
      final values = errors.values
          .where((value) => value != null && value.toString().trim().isNotEmpty)
          .map((value) => value.toString())
          .toList();
      if (values.isNotEmpty) {
          return '${_providerLabel(json)}: ${values.join(' ')}';
      }
    }

    if (errors is List) {
      final values = errors
          .where((value) => value != null && value.toString().trim().isNotEmpty)
          .map((value) => value.toString())
          .toList();
      if (values.isNotEmpty) {
          return '${_providerLabel(json)}: ${values.join(' ')}';
      }
    }

    return '${_providerLabel(json)} returned an error.';
  }

  String _providerLabel(Map<String, dynamic> json) {
    final provider = json['provider'];
    if (provider == null || provider.toString().trim().isEmpty) {
      return 'Football API';
    }
    return provider.toString();
  }
}
