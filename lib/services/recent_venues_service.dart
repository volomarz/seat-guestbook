import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/league.dart';
import '../models/stadium.dart';

/// Remembers venues someone has looked up before via search (concert
/// venues, NASCAR tracks — anything not on a fixed browsable list),
/// on-device only (same lightweight approach as ProfileService), so they
/// don't have to re-search every time they want to sign another seat there.
class RecentVenuesService {
  static const _key = 'recentSearchedVenues';
  static const _maxEntries = 40;

  /// Returns recently viewed venues, most recent first. Pass [league] to
  /// filter to just one searchable league (e.g. only NASCAR tracks); omit
  /// it to get everything.
  static Future<List<Stadium>> getRecent({League? league}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final all = list
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .whereType<Stadium>()
          .toList();
      if (league == null) return all;
      return all.where((s) => s.league == league).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addRecent(Stadium stadium) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getRecent();
    current.removeWhere((s) => s.id == stadium.id);
    current.insert(0, stadium);
    final capped = current.take(_maxEntries).toList();
    final raw = jsonEncode(capped.map(_toJson).toList());
    await prefs.setString(_key, raw);
  }

  static Map<String, dynamic> _toJson(Stadium s) => {
        'id': s.id,
        'name': s.name,
        'city': s.city,
        'league': s.league.name,
      };

  static Stadium? _fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    final city = json['city'] as String?;
    if (id == null || name == null || city == null) return null;
    final leagueName = json['league'] as String?;
    final league = League.values.firstWhere(
      (l) => l.name == leagueName,
      orElse: () => League.concert, // entries saved before NASCAR existed
    );
    return Stadium(id: id, name: name, team: '', city: city, league: league);
  }
}
