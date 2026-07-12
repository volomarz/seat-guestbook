import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/standings.dart';

class NhlStandingsService {
  /// ESPN doesn't publish real standings for a season until regular-season
  /// games start in October — before then (including September preseason),
  /// that season has zero teams in it. So the season we should ask
  /// standings for is the most recently *completed* one until games are
  /// actually being played again. NHL seasons are labeled by the year they
  /// *end* in (season=2026 means the "2025-26" season).
  static int _mostRecentSeasonYear() {
    final now = DateTime.now();
    return now.month >= 10 ? now.year + 1 : now.year;
  }

  /// The season year fetchStandings() will query under normal conditions
  /// (exposed so the UI can label what's on screen, e.g. "2025-26 season").
  static int currentSeason() => _mostRecentSeasonYear();

  /// Returns Eastern/Western conference standings, using NHL points
  /// (2 per win, 1 per OT/shootout loss) rather than win percentage —
  /// that's how NHL standings are actually read, unlike MLB/NFL.
  static Future<List<StandingsDivision>> fetchStandings() async {
    final season = _mostRecentSeasonYear();
    var divisions = await _fetchForSeason(season);
    // Defensive fallback in case ESPN hasn't populated this season yet.
    if (divisions.isEmpty) {
      divisions = await _fetchForSeason(season - 1);
    }
    return divisions;
  }

  static Future<List<StandingsDivision>> _fetchForSeason(int season) async {
    final url = Uri.parse(
      'https://site.api.espn.com/apis/v2/sports/hockey/nhl/standings'
      '?season=$season',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Failed to load standings');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final children = data['children'] as List<dynamic>? ?? [];
    final divisions = <StandingsDivision>[];

    for (final c in children) {
      final conference = c as Map<String, dynamic>;
      final name = conference['name'] as String? ?? 'Conference';
      final standings = conference['standings'] as Map<String, dynamic>?;
      final entries = standings?['entries'] as List<dynamic>? ?? [];
      final teams = <StandingsTeam>[];

      for (final e in entries) {
        final entry = e as Map<String, dynamic>;
        final team = entry['team'] as Map<String, dynamic>?;
        final stats = entry['stats'] as List<dynamic>? ?? [];
        String statValue(String key, String fallback) {
          for (final s in stats) {
            final stat = s as Map<String, dynamic>;
            if (stat['name'] == key) {
              return (stat['displayValue'] as String?) ?? fallback;
            }
          }
          return fallback;
        }

        final losses = int.tryParse(statValue('losses', '0')) ?? 0;
        final otLosses = int.tryParse(statValue('otLosses', '0')) ?? 0;

        teams.add(StandingsTeam(
          name: team?['displayName'] as String? ?? 'Team',
          wins: int.tryParse(statValue('wins', '0')) ?? 0,
          losses: losses + otLosses, // combined for the simple W/L display
          pct: statValue('points', '0'), // NHL ranks by points, not win %
          gamesBack: statValue('gamesBehind', '-'),
        ));
      }

      // Rank by points, matching how NHL standings are actually read.
      teams.sort((a, b) => (int.tryParse(b.pct) ?? 0).compareTo(int.tryParse(a.pct) ?? 0));
      divisions.add(StandingsDivision(name: name, teams: teams));
    }

    divisions.sort((a, b) => a.name.compareTo(b.name));
    return divisions;
  }
}
