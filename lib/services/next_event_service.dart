import '../models/stadium.dart';
import '../models/venue_event.dart';
import 'sports_service.dart';
import 'ticketmaster_service.dart';

class NextEventService {
  static Future<VenueEvent?> fetchNextEvent(Stadium stadium) async {
    final results = await Future.wait([
      SportsService.fetchNextGame(stadium),
      TicketmasterService.fetchNextEvent(stadium.name, stadium.city),
    ]);
    final game = results[0];
    final concert = results[1];
    if (game == null) return concert;
    if (concert == null) return game;
    return game.dateTime.isBefore(concert.dateTime) ? game : concert;
  }
}