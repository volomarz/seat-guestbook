import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../data/mlb_team_ids.dart';
import '../models/venue_event.dart';

class MlbStatsService {
  /// Looks up the score for the given stadium's team on the given date
  /// (yyyy-MM-dd). Returns a short summary like "Yankees 7, Red Sox 3 (Final)",
  /// or null if no game is found or the lookup fails.
  static Future<String?> fetchGameSummary(String stadiumId, String date) async {
    final teamId = kMlbTeamIds[stadiumId];
    if (teamId == null) return null;
    final url = Uri.parse(
      'https://statsapi.mlb.com/api/v1/schedule?sportId=1&teamId=$teamId&date=$date',
    );
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final dates = data['dates'] as List<dynamic>?;
      if (dates == null || dates.isEmpty) return null;
      final games = (dates.first as Map<String, dynamic>)['games'] as List<dynamic>?;
      if (games == null || games.isEmpty) return null;
      final game = games.first as Map<String, dynamic>;
      final status = (game['status'] as Map<String, dynamic>)['detailedState'] as String? ?? '';
      final teams = game['teams'] as Map<String, dynamic>;
      final away = teams['away'] as Map<String, dynamic>;
      final home = teams['home'] as Map<String, dynamic>;
      final awayName = ((away['team'] as Map<String, dynamic>)['name'] as String?) ?? 'Away';
      final homeName = ((home['team'] as Map<String, dynamic>)['name'] as String?) ?? 'Home';
      final awayScore = away['score'];
      final homeScore = home['score'];

      if (status == 'Final' && awayScore != null && homeScore != null) {
        return '$awayName $awayScore, $homeName $homeScore (Final)';
      } else if (status.isNotEmpty) {
        return '$awayName @ $homeName ($status)';
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Finds the next upcoming (not-yet-final) game for the given stadium's
  /// team, looking up to 30 days ahead. Returns null if none is found.
  static Future<VenueEvent?> fetchNextGame(String stadiumId) async {
    final teamId = kMlbTeamIds[stadiumId];
    if (teamId == null) return null;
    final now = DateTime.now();
    final start = _fmt(now);
    final end = _fmt(now.add(const Duration(days: 30)));
    final url = Uri.parse(
      'https://statsapi.mlb.com/api/v1/schedule?sportId=1&teamId=$teamId&startDate=$start&endDate=$end',
    );
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final dates = data['dates'] as List<dynamic>?;
      if (dates == null) return null;

      for (final d in dates) {
        final games = (d as Map<String, dynamic>)['games'] as List<dynamic>?;
        if (games == null) continue;
        for (final g in games) {
          final game = g as Map<String, dynamic>;
          final status =
              (game['status'] as Map<String, dynamic>)['detailedState'] as String? ?? '';
          final lowerStatus = status.toLowerCase();
          if (lowerStatus.contains('final') ||
              lowerStatus.contains('postponed') ||
              lowerStatus.contains('cancel')) {
            continue;
          }
          final gameDateStr = game['gameDate'] as String?;
          if (gameDateStr == null) continue;
          final gameDate = DateTime.tryParse(gameDateStr);
          if (gameDate == null) continue;
          if (gameDate.isBefore(now.subtract(const Duration(hours: 4)))) continue;

          final teams = game['teams'] as Map<String, dynamic>;
          final away = teams['away'] as Map<String, dynamic>;
          final home = teams['home'] as Map<String, dynamic>;
          final awayName = ((away['team'] as Map<String, dynamic>)['name'] as String?) ?? 'Away';
          final homeName = ((home['team'] as Map<String, dynamic>)['name'] as String?) ?? 'Home';
          final local = gameDate.toLocal();

          return VenueEvent(
            type: VenueEventType.game,
            title: '$awayName @ $homeName',
            subtitle: DateFormat('EEE, MMM d \u00b7 h:mm a').format(local),
            dateTime: local,
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}