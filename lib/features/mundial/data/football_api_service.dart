import '../../../core/network/api_client.dart';

class FootballApiService {
  const FootballApiService(this._client);

  final ApiClient _client;

  bool get isConfigured => _client.isConfigured;

  Future<Map<String, dynamic>> fetchFixtures({
    required int season,
    String timezone = 'America/Lima',
  }) {
    return _client.invoke(<String, Object?>{
      'resource': 'fixtures',
      'season': season,
      'timezone': timezone,
    });
  }

  Future<Map<String, dynamic>> fetchStandings({
    required int season,
  }) {
    return _client.invoke(<String, Object?>{
      'resource': 'standings',
      'season': season,
    });
  }

  Future<Map<String, dynamic>> fetchTeams({
    required int season,
  }) {
    return _client.invoke(<String, Object?>{
      'resource': 'teams',
      'season': season,
    });
  }

  Future<Map<String, dynamic>> fetchFixtureDetail({
    required int fixtureId,
    required int season,
  }) {
    return _client.invoke(<String, Object?>{
      'resource': 'fixture',
      'id': fixtureId,
      'season': season,
    });
  }
}
