import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/standings.dart';
import '../models/super_bowl_result.dart';

class NflStandingsService {
  /// ESPN doesn't publish any standings for a season until it actually
  /// starts (regular-season games begin in September) — during the
  /// off-season, the "current" season year has zero teams in it. So unlike
  /// schedule lookups (which ESPN publishes months ahead of kickoff), the
  /// season we should ask standings for is the most recently *completed*
  /// one until games are actually being played again.
  static int _mostRecentSeasonYear() {
    final now = DateTime.now();
    return now.month <= 8 ? now.year - 1 : now.year;
  }

  /// The season year fetchStandings() will query under normal conditions
  /// (exposed so the UI can label what's on screen, e.g. "2025 season").
  static int currentSeason() => _mostRecentSeasonYear();

  /// Returns AFC/NFC conference standings (ESPN's NFL standings endpoint
  /// doesn't reliably expose the 8 individual divisions the way the MLB
  /// Stats API does, so this shows the two conferences instead).
  static Future<List<StandingsDivision>> fetchStandings() async {
    final season = _mostRecentSeasonYear();
    var divisions = await _fetchForSeason(season);
    // Defensive fallback: if ESPN hasn't populated this season yet for any
    // reason, fall back a year so the screen never shows an empty state
    // when a real, completed season's standings do exist.
    if (divisions.isEmpty) {
      divisions = await _fetchForSeason(season - 1);
    }
    return divisions;
  }

  /// Returns the Super Bowl result for the given season (e.g. season: 2025
  /// for the Super Bowl played in February 2026), or null if that season's
  /// Super Bowl hasn't been played yet or the lookup fails. ESPN files the
  /// postseason as seasontype=3, and week=5 is always the Super Bowl
  /// (1=Wild Card, 2=Divisional, 3=Conference Championship, 4=Pro Bowl).
  static Future<SuperBowlResult?> fetchSuperBowlResult(int season) async {
    final url = Uri.parse(
      'https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard'
      '?seasontype=3&week=5&dates=$season',
    );
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final events = data['events'] as List<dynamic>?;
      if (events == null || events.isEmpty) return null;
      final event = events.first as Map<String, dynamic>;

      final competitions = event['competitions'] as List<dynamic>?;
      if (competitions == null || competitions.isEmpty) return null;
      final competition = competitions.first as Map<String, dynamic>;

      final status = competition['status'] as Map<String, dynamic>?;
      final type = status?['type'] as Map<String, dynamic>?;
      if (type?['state'] != 'post') return null; // not played yet

      final competitors = competition['competitors'] as List<dynamic>? ?? [];
      Map<String, dynamic>? winner;
      Map<String, dynamic>? loser;
      for (final c in competitors) {
        final comp = c as Map<String, dynamic>;
        if (comp['winner'] == true) {
          winner = comp;
        } else {
          loser = comp;
        }
      }
      if (winner == null || loser == null) return null;

      final notes = competition['notes'] as List<dynamic>?;
      final headline = (notes != null && notes.isNotEmpty)
          ? (notes.first as Map<String, dynamic>)['headline'] as String?
          : null;
      final dateStr = event['date'] as String?;
      final date = dateStr != null ? DateTime.tryParse(dateStr)?.toLocal() : null;

      return SuperBowlResult(
        headline: headline ?? 'Super Bowl',
        date: date,
        winnerName:
            (winner['team'] as Map<String, dynamic>?)?['displayName'] as String? ?? 'Winner',
        winnerScore: winner['score'] as String? ?? '',
        loserName: (loser['team'] as Map<String, dynamic>?)?['displayName'] as String? ?? 'Loser',
        loserScore: loser['score'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  static Future<List<StandingsDivision>> _fetchForSeason(int season) async {
    final url = Uri.parse(
      'https://site.api.espn.com/apis/v2/sports/football/nfl/standings'
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

        teams.add(StandingsTeam(
          name: team?['displayName'] as String? ?? 'Team',
          wins: int.tryParse(statValue('wins', '0')) ?? 0,
          losses: int.tryParse(statValue('losses', '0')) ?? 0,
          pct: statValue('winPercent', '.000'),
          gamesBack: statValue('gamesBehind', '-'),
        ));
      }

      // Higher win percentage first, matching how standings are conventionally read.
      teams.sort((a, b) => b.wins.compareTo(a.wins));
      divisions.add(StandingsDivision(name: name, teams: teams));
    }

    divisions.sort((a, b) => a.name.compareTo(b.name));
    return divisions;
  }
}
