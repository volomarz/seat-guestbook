import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../data/nhl_team_ids.dart';
import '../models/venue_event.dart';

class NhlStatsService {
  /// ESPN labels an NHL season by the year it *ends* in (e.g. the game
  /// played in January 2026 belongs to the "2025-26 season", queried as
  /// season=2026) — the opposite convention from NFL/MLB. September
  /// preseason games already belong to the *next* season's schedule, so
  /// September rolls forward too.
  static int _seasonFor(DateTime d) => d.month >= 9 ? d.year + 1 : d.year;

  /// Looks up the score for the given stadium's team on the given date
  /// (yyyy-MM-dd). Returns a short summary like "Bruins 4, Rangers 3
  /// (Final)", or null if no game is found or the lookup fails.
  static Future<String?> fetchGameSummary(String stadiumId, String date) async {
    final abbr = kNhlTeamAbbr[stadiumId];
    if (abbr == null) return null;
    final requestedDate = DateTime.tryParse(date);
    if (requestedDate == null) return null;
    final season = _seasonFor(requestedDate);

    final events = await _fetchSeasonEvents(abbr, season);
    if (events == null) return null;

    for (final event in events) {
      final competition = _competitionOf(event);
      if (competition == null) continue;
      final gameDateStr = event['date'] as String?;
      if (gameDateStr == null) continue;
      final gameDate = DateTime.tryParse(gameDateStr);
      if (gameDate == null) continue;
      final localDateStr = DateFormat('yyyy-MM-dd').format(gameDate.toLocal());
      if (localDateStr != date) continue;

      final summary = _summarize(competition);
      if (summary != null) return summary;
    }
    return null;
  }

  /// Finds the next upcoming (not-yet-final) game for the given stadium's
  /// team. Returns null if none is found — including during the summer
  /// off-season before the next schedule has been published.
  static Future<VenueEvent?> fetchNextGame(String stadiumId) async {
    final abbr = kNhlTeamAbbr[stadiumId];
    if (abbr == null) return null;
    final now = DateTime.now();
    final season = _seasonFor(now);

    final events = await _fetchSeasonEvents(abbr, season);
    if (events == null) return null;

    for (final event in events) {
      final competition = _competitionOf(event);
      if (competition == null) continue;
      final status = _statusState(competition);
      if (status == 'post') continue;

      final gameDateStr = event['date'] as String?;
      if (gameDateStr == null) continue;
      final gameDate = DateTime.tryParse(gameDateStr);
      if (gameDate == null) continue;
      final local = gameDate.toLocal();
      if (local.isBefore(now.subtract(const Duration(hours: 4)))) continue;

      return VenueEvent(
        type: VenueEventType.game,
        title: _competitorNames(competition),
        subtitle: DateFormat('EEE, MMM d · h:mm a').format(local),
        dateTime: local,
      );
    }
    return null;
  }

  static Future<List<dynamic>?> _fetchSeasonEvents(String abbr, int season) async {
    final url = Uri.parse(
      'https://site.api.espn.com/apis/site/v2/sports/hockey/nhl/teams/$abbr/schedule?season=$season',
    );
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['events'] as List<dynamic>?;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _competitionOf(dynamic event) {
    final competitions = (event as Map<String, dynamic>)['competitions'] as List<dynamic>?;
    if (competitions == null || competitions.isEmpty) return null;
    return competitions.first as Map<String, dynamic>;
  }

  static String _statusState(Map<String, dynamic> competition) {
    final status = competition['status'] as Map<String, dynamic>?;
    final type = status?['type'] as Map<String, dynamic>?;
    return (type?['state'] as String?) ?? '';
  }

  static String _competitorNames(Map<String, dynamic> competition) {
    final competitors = competition['competitors'] as List<dynamic>? ?? [];
    Map<String, dynamic>? home;
    Map<String, dynamic>? away;
    for (final c in competitors) {
      final comp = c as Map<String, dynamic>;
      if (comp['homeAway'] == 'home') home = comp;
      if (comp['homeAway'] == 'away') away = comp;
    }
    final awayName = ((away?['team'] as Map<String, dynamic>?)?['displayName'] as String?) ?? 'Away';
    final homeName = ((home?['team'] as Map<String, dynamic>?)?['displayName'] as String?) ?? 'Home';
    return '$awayName @ $homeName';
  }

  static String? _summarize(Map<String, dynamic> competition) {
    final status = competition['status'] as Map<String, dynamic>?;
    final type = status?['type'] as Map<String, dynamic>?;
    final state = (type?['state'] as String?) ?? '';
    final description = (type?['description'] as String?) ?? '';

    final competitors = competition['competitors'] as List<dynamic>? ?? [];
    Map<String, dynamic>? home;
    Map<String, dynamic>? away;
    for (final c in competitors) {
      final comp = c as Map<String, dynamic>;
      if (comp['homeAway'] == 'home') home = comp;
      if (comp['homeAway'] == 'away') away = comp;
    }
    if (home == null || away == null) return null;

    final awayName = ((away['team'] as Map<String, dynamic>?)?['displayName'] as String?) ?? 'Away';
    final homeName = ((home['team'] as Map<String, dynamic>?)?['displayName'] as String?) ?? 'Home';

    if (state == 'post') {
      final awayScore = (away['score'] as Map<String, dynamic>?)?['displayValue'] as String?;
      final homeScore = (home['score'] as Map<String, dynamic>?)?['displayValue'] as String?;
      if (awayScore != null && homeScore != null) {
        return '$awayName $awayScore, $homeName $homeScore (Final)';
      }
    }
    if (description.isNotEmpty) {
      return '$awayName @ $homeName ($description)';
    }
    return null;
  }
}
