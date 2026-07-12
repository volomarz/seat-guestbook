import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/standings.dart';

class StandingsService {
  /// leagueId 103 = American League, 104 = National League.
  /// MLB division IDs are fixed; used as a fallback when the API
  /// occasionally omits the "name" field on a division object.
  static const Map<int, String> _divisionNames = {
    200: 'American League West',
    201: 'American League East',
    202: 'American League Central',
    203: 'National League West',
    204: 'National League East',
    205: 'National League Central',
  };

  static Future<List<StandingsDivision>> fetchStandings() async {
    final season = DateTime.now().year;
    final url = Uri.parse(
      'https://statsapi.mlb.com/api/v1/standings'
      '?leagueId=103,104&season=$season&standingsTypes=regularSeason',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Failed to load standings');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final records = data['records'] as List<dynamic>? ?? [];
    final divisions = <StandingsDivision>[];

    for (final r in records) {
      final record = r as Map<String, dynamic>;
      final division = record['division'] as Map<String, dynamic>?;
      final divisionId = division?['id'] as int?;
      final divisionName = (division?['name'] as String?) ??
          _divisionNames[divisionId] ??
          'Division';
      final teamRecords = record['teamRecords'] as List<dynamic>? ?? [];
      final teams = <StandingsTeam>[];

      for (final tr in teamRecords) {
        final teamRecord = tr as Map<String, dynamic>;
        final team = teamRecord['team'] as Map<String, dynamic>?;
        teams.add(StandingsTeam(
          name: team?['name'] as String? ?? 'Team',
          wins: teamRecord['wins'] as int? ?? 0,
          losses: teamRecord['losses'] as int? ?? 0,
          pct: teamRecord['winningPercentage'] as String? ?? '.000',
          gamesBack: teamRecord['gamesBack'] as String? ?? '-',
        ));
      }
      divisions.add(StandingsDivision(name: divisionName, teams: teams));
    }

    divisions.sort((a, b) => a.name.compareTo(b.name));
    return divisions;
  }
}