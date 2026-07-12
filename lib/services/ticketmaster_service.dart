import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/api_keys.dart';
import '../models/venue_event.dart';
import '../models/venue_search_result.dart';

class TicketmasterService {
  /// Looks up real venues by name (any venue Ticketmaster knows about, not
  /// just a fixed list) — used for the "find a concert venue" search.
  /// Returns an empty list if the query is too short or the lookup fails.
  static Future<List<VenueSearchResult>> searchVenues(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final url = Uri.parse(
      'https://app.ticketmaster.com/discovery/v2/venues.json'
      '?apikey=$kTicketmasterApiKey&keyword=${Uri.encodeComponent(trimmed)}&size=20',
    );
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final embedded = data['_embedded'] as Map<String, dynamic>?;
      final venues = embedded?['venues'] as List<dynamic>?;
      if (venues == null) return [];

      final results = <VenueSearchResult>[];
      final seen = <String>{};
      for (final v in venues) {
        final venue = v as Map<String, dynamic>;
        final id = venue['id'] as String?;
        final name = venue['name'] as String?;
        final city = (venue['city'] as Map<String, dynamic>?)?['name'] as String?;
        if (id == null || name == null || city == null) {
          continue; // skip low-quality/duplicate entries missing basic info
        }
        final state = (venue['state'] as Map<String, dynamic>?)?['stateCode'] as String? ?? '';
        final dedupeKey = '${name.toLowerCase()}|${city.toLowerCase()}';
        if (!seen.add(dedupeKey)) continue;

        results.add(VenueSearchResult(
          ticketmasterId: id,
          name: name,
          city: city,
          state: state,
        ));
        if (results.length >= 15) break;
      }
      return results;
    } catch (_) {
      return [];
    }
  }

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
          imageUrl: _bestImageUrl(event['images'] as List<dynamic>?),
          venueName: _venueField(event, 'name') as String?,
          venueAddress: _venueAddress(event),
          priceRange: _priceRangeText(event['priceRanges'] as List<dynamic>?),
          onsaleStatus: _onsaleStatusText(dates),
          ticketUrl: event['url'] as String?,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Picks a good hero image: prefers a wide (16:9) shot, falls back to
  /// whichever image is largest, since Ticketmaster returns a dozen+ crops.
  static String? _bestImageUrl(List<dynamic>? images) {
    if (images == null || images.isEmpty) return null;
    final list = images.cast<Map<String, dynamic>>();
    final wide = list.where((im) => im['ratio'] == '16_9').toList();
    final pool = wide.isNotEmpty ? wide : list;
    pool.sort((a, b) => ((b['width'] as int?) ?? 0).compareTo((a['width'] as int?) ?? 0));
    return pool.first['url'] as String?;
  }

  static dynamic _venueField(Map<String, dynamic> event, String key) {
    final embedded = event['_embedded'] as Map<String, dynamic>?;
    final venues = embedded?['venues'] as List<dynamic>?;
    if (venues == null || venues.isEmpty) return null;
    return (venues.first as Map<String, dynamic>)[key];
  }

  static String? _venueAddress(Map<String, dynamic> event) {
    final embedded = event['_embedded'] as Map<String, dynamic>?;
    final venues = embedded?['venues'] as List<dynamic>?;
    if (venues == null || venues.isEmpty) return null;
    final venue = venues.first as Map<String, dynamic>;
    final address = venue['address'] as Map<String, dynamic>?;
    final line1 = address?['line1'] as String?;
    final city = (venue['city'] as Map<String, dynamic>?)?['name'] as String?;
    final state = (venue['state'] as Map<String, dynamic>?)?['stateCode'] as String?;
    final parts = [line1, [city, state].where((s) => s != null && s.isNotEmpty).join(', ')]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.join('\n');
  }

  static String? _priceRangeText(List<dynamic>? priceRanges) {
    if (priceRanges == null || priceRanges.isEmpty) return null;
    final range = priceRanges.first as Map<String, dynamic>;
    final min = range['min'];
    final max = range['max'];
    final currency = range['currency'] as String? ?? 'USD';
    final symbol = currency == 'USD' ? '\$' : '$currency ';
    if (min == null || max == null) return null;
    final minStr = (min as num).toStringAsFixed(0);
    final maxStr = (max as num).toStringAsFixed(0);
    return minStr == maxStr ? '$symbol$minStr' : '$symbol$minStr\u2013$symbol$maxStr';
  }

  static String? _onsaleStatusText(Map<String, dynamic>? dates) {
    final code = (dates?['status'] as Map<String, dynamic>?)?['code'] as String?;
    switch (code) {
      case 'onsale':
        return 'On sale now';
      case 'offsale':
        return 'Not currently on sale';
      case 'cancelled':
        return 'Cancelled';
      case 'postponed':
        return 'Postponed';
      case 'rescheduled':
        return 'Rescheduled';
      default:
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