import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/mlb_team_ids.dart';

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
}