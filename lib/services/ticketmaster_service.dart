import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/api_keys.dart';
import '../models/venue_event.dart';

class TicketmasterService {
  /// Finds the next non-sports event (concert, etc.) at the venue matching
  /// [venueName]/[city]. Returns null if none is found or the lookup fails.
  static Future<VenueEvent?> fetchNextEvent(String venueName, String city) async {
    try {
      final venueId = await _findVenueId(venueName, city);
      if (venueId == null) return null;

      final url = Uri.parse(
        'https://app.ticketmaster.com/discovery/v2/events.json'
        '?apikey=$kTicketmasterApiKey&venueId=$venueId&sort=date,asc&size=20',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final embedded = data['_embedded'] as Map<String, dynamic>?;
      final events = embedded?['events'] as List<dynamic>?;
      if (events == null) return null;

      for (final e in events) {
        final event = e as Map<String, dynamic>;

        String? segment;
        final classifications = event['classifications'] as List<dynamic>?;
        if (classifications != null && classifications.isNotEmpty) {
          final first = classifications.first as Map<String, dynamic>;
          final segmentMap = first['segment'] as Map<String, dynamic>?;
          segment = segmentMap?['name'] as String?;
        }
        if (segment == 'Sports') continue; // MLB games are handled separately

        final name = event['name'] as String? ?? 'Event';
        final dates = event['dates'] as Map<String, dynamic>?;
        final start = dates?['start'] as Map<String, dynamic>?;

        DateTime? dt;
        final dateTimeStr = start?['dateTime'] as String?;
        if (dateTimeStr != null) {
          dt = DateTime.tryParse(dateTimeStr)?.toLocal();
        } else {
          final localDate = start?['localDate'] as String?;
          if (localDate != null) dt = DateTime.tryParse(localDate);
        }
        if (dt == null) continue;

        return VenueEvent(
          type: VenueEventType.concert,
          title: name,
          subtitle: DateFormat('EEE, MMM d \u00b7 h:mm a').format(dt),
          dateTime: dt,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _findVenueId(String venueName, String city) async {
    final url = Uri.parse(
      'https://app.ticketmaster.com/discovery/v2/venues.json'
      '?apikey=$kTicketmasterApiKey&keyword=${Uri.encodeComponent(venueName)}&size=5',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final embedded = data['_embedded'] as Map<String, dynamic>?;
    final venues = embedded?['venues'] as List<dynamic>?;
    if (venues == null || venues.isEmpty) return null;

    for (final v in venues) {
      final venue = v as Map<String, dynamic>;
      final venueCity = (venue['city'] as Map<String, dynamic>?)?['name'] as String?;
      if (venueCity != null && venueCity.toLowerCase() == city.toLowerCase()) {
        return venue['id'] as String?;
      }
    }
    return (venues.first as Map<String, dynamic>)['id'] as String?;
  }
}