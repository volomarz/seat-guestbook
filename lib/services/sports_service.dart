import '../models/league.dart';
import '../models/stadium.dart';
import '../models/venue_event.dart';
import 'mlb_stats_service.dart';
import 'nfl_stats_service.dart';

/// Routes score/schedule lookups to the right per-league service based on
/// the stadium's league. Add a case here whenever a new sport is added.
class SportsService {
  static Future<String?> fetchGameSummary(Stadium stadium, String date) {
    switch (stadium.league) {
      case League.mlb:
        return MlbStatsService.fetchGameSummary(stadium.id, date);
      case League.nfl:
        return NflStatsService.fetchGameSummary(stadium.id, date);
    }
  }

  static Future<VenueEvent?> fetchNextGame(Stadium stadium) {
    switch (stadium.league) {
      case League.mlb:
        return MlbStatsService.fetchNextGame(stadium.id);
      case League.nfl:
        return NflStatsService.fetchNextGame(stadium.id);
    }
  }
}
